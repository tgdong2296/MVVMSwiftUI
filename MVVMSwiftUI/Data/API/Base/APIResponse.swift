//
//  APIResponse.swift
//  VMPatternSwiftUI
//

import Foundation

/// Base API response wrapper matching common server response format
struct APIResponse<T: Decodable>: Decodable, @unchecked Sendable {
    let statusCode: Int?
    let message: String?
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case message
        case data
    }
}

/// Empty response type for endpoints that return no data
struct EmptyResponse: Decodable, Sendable {}
