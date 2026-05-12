//
//  APIError.swift
//  VMPatternSwiftUI
//

import Foundation
import Moya

// MARK: - API Error Response (from server)

struct APIErrorResponse: Sendable {
    let statusCode: Int?
    let message: String?
    let errors: [String: [String]]?
    
    /// Returns a flattened description of validation errors
    var validationMessage: String? {
        errors?.flatMap { $0.value }.joined(separator: "\n")
    }
}

extension APIErrorResponse: Decodable {
    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)
    }
    
    private enum CodingKeys: String, CodingKey {
        case statusCode, message, errors
    }
}

// MARK: - API Error

enum APIError: LocalizedError {
    case network(statusCode: Int, response: APIErrorResponse?)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case tokenRefreshFailed
    case noInternetConnection
    case timeout
    case cancelled
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .network(_, let response):
            return response?.message ?? response?.validationMessage ?? "An unexpected error occurred."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .forbidden:
            return "You do not have permission to perform this action."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let statusCode):
            return "Server error (\(statusCode)). Please try again later."
        case .decodingFailed:
            return "Failed to process the server response."
        case .tokenRefreshFailed:
            return "Session refresh failed. Please log in again."
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        case .timeout:
            return "The request timed out. Please try again."
        case .cancelled:
            return "The request was cancelled."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
    
    var statusCode: Int? {
        switch self {
        case .network(let code, _):
            return code
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .serverError(let code):
            return code
        default:
            return nil
        }
    }
    
    var isUnauthorized: Bool {
        switch self {
        case .unauthorized, .tokenRefreshFailed:
            return true
        default:
            return false
        }
    }
}
