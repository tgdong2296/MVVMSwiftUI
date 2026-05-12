//
//  BaseTargetType.swift
//  VMPatternSwiftUI
//

import Foundation
@preconcurrency import Moya

/// Base protocol extending Moya's TargetType with common configuration.
/// All API target enums should conform to this protocol.
protocol BaseTargetType: TargetType, AccessTokenAuthorizable {
    /// Whether this request requires authentication (Bearer token).
    /// Defaults to `true`.
    var requiresAuth: Bool { get }
}

extension BaseTargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Environments.baseURL) else {
            fatalError("Invalid BASE_URL in environment configuration")
        }
        return url
    }
    
    var requiresAuth: Bool {
        true
    }
    
    var authorizationType: AuthorizationType? {
        requiresAuth ? .bearer : .none
    }
    
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var validationType: ValidationType {
        .successCodes
    }
}
