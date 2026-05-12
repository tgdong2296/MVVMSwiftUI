//
//  TokenRefreshCoordinator.swift
//  VMPatternSwiftUI
//

import Foundation
import Alamofire
@preconcurrency import Moya

/// Type alias to avoid conflict with `Moya.Task`
private typealias AsyncTask = _Concurrency.Task

/// Coordinates token refresh to prevent data races.
/// When multiple requests get a 401 simultaneously, only ONE refresh
/// call is made. All other callers await the same result.
///
/// Uses `@MainActor` to satisfy Moya's TargetType isolation requirements.
/// The actual network call is non-blocking (async continuation).
@MainActor
final class TokenRefreshCoordinator {
    
    /// The in-flight refresh task, if any. Multiple callers will await the same task.
    private var refreshTask: AsyncTask<Void, Error>?
    
    private let provider: MoyaProvider<AuthTarget>
    private let jsonDecoder: JSONDecoder
    
    init(
        provider: MoyaProvider<AuthTarget>,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.provider = provider
        self.jsonDecoder = jsonDecoder
    }
    
    /// Refreshes the access token if needed.
    /// If a refresh is already in-flight, callers will await the same task
    /// instead of triggering a second refresh.
    func refreshTokenIfNeeded(tokenManager: TokenManager) async throws {
        // If there's already a refresh in progress, just await it
        if let existingTask = refreshTask {
            try await existingTask.value
            return
        }
        
        // Start a new refresh task
        let provider = self.provider
        let jsonDecoder = self.jsonDecoder
        
        let task = AsyncTask { @MainActor in
            guard let refreshToken = await tokenManager.refreshToken else {
                throw APIError.tokenRefreshFailed
            }
            
            let response: Response = try await withCheckedThrowingContinuation { continuation in
                provider.request(.refreshToken(refreshToken: refreshToken)) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: APIErrorParser.parse(error))
                    }
                }
            }
            
            // Validate response status
            guard (200...299).contains(response.statusCode) else {
                throw APIError.tokenRefreshFailed
            }
            
            // Decode the new tokens
            let tokenResponse = try jsonDecoder.decode(
                APIResponse<TokenResponse>.self,
                from: response.data
            )
            
            guard let tokens = tokenResponse.data else {
                throw APIError.tokenRefreshFailed
            }
            
            // Update stored tokens
            await tokenManager.updateTokens(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
        }
        
        refreshTask = task
        
        // Clean up after completion (success or failure)
        defer { refreshTask = nil }
        
        try await task.value
    }
}

// MARK: - Auth Target (for refresh token endpoint)

enum AuthTarget: BaseTargetType, Sendable {
    case refreshToken(refreshToken: String)
    
    var path: String {
        switch self {
        case .refreshToken:
            return "/auth/refresh-token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .refreshToken:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .refreshToken(let refreshToken):
            return .requestParameters(
                parameters: ["refreshToken": refreshToken],
                encoding: JSONEncoding.default
            )
        }
    }
    
    var requiresAuth: Bool {
        false
    }
}

// MARK: - Token Response

struct TokenResponse: Sendable {
    let accessToken: String
    let refreshToken: String
}

extension TokenResponse: Decodable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
    
    private enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
}
