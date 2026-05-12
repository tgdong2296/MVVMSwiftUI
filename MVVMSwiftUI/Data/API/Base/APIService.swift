//
//  APIService.swift
//  VMPatternSwiftUI
//

import Foundation
@preconcurrency import Moya

/// A generic API provider that wraps Moya with async/await support,
/// automatic token injection, and data-race-safe token refresh.
final class APIService<Target: BaseTargetType>: @unchecked Sendable {
    
    private let provider: MoyaProvider<Target>
    private let tokenManager: TokenManager
    private let refreshCoordinator: TokenRefreshCoordinator
    private let jsonDecoder: JSONDecoder
    
    init(
        provider: MoyaProvider<Target>,
        tokenManager: TokenManager,
        refreshCoordinator: TokenRefreshCoordinator,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.provider = provider
        self.tokenManager = tokenManager
        self.refreshCoordinator = refreshCoordinator
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - Public API
    
    /// Performs a request and decodes the response into the given type.
    func request<T: Decodable>(_ target: Target, type: T.Type) async throws -> T {
        do {
            let response = try await performRequest(target)
            return try jsonDecoder.decode(T.self, from: response.data)
        } catch let apiError as APIError where apiError.isUnauthorized {
            try await refreshCoordinator.refreshTokenIfNeeded(tokenManager: tokenManager)
            let response = try await performRequest(target)
            return try jsonDecoder.decode(T.self, from: response.data)
        } catch let apiError as APIError {
            throw apiError
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.unknown(error)
        }
    }
    
    /// Performs a request that wraps the response in an `APIResponse<T>`.
    func requestWrapped<T: Decodable>(_ target: Target, type: T.Type) async throws -> APIResponse<T> {
        do {
            let response = try await performRequest(target)
            return try jsonDecoder.decode(APIResponse<T>.self, from: response.data)
        } catch let apiError as APIError where apiError.isUnauthorized {
            try await refreshCoordinator.refreshTokenIfNeeded(tokenManager: tokenManager)
            let response = try await performRequest(target)
            return try jsonDecoder.decode(APIResponse<T>.self, from: response.data)
        } catch let apiError as APIError {
            throw apiError
        } catch let error as DecodingError {
            throw APIError.decodingFailed(error)
        } catch {
            throw APIError.unknown(error)
        }
    }
    
    /// Performs a request that expects no response body.
    func requestVoid(_ target: Target) async throws {
        do {
            _ = try await performRequest(target)
        } catch let apiError as APIError where apiError.isUnauthorized {
            try await refreshCoordinator.refreshTokenIfNeeded(tokenManager: tokenManager)
            _ = try await performRequest(target)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.unknown(error)
        }
    }
    
    // MARK: - Private
    
    private func performRequest(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let moyaError):
                    continuation.resume(throwing: APIErrorParser.parse(moyaError))
                }
            }
        }
    }
}
