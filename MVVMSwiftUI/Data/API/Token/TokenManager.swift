//
//  TokenManager.swift
//  VMPatternSwiftUI
//

import Foundation
import FactoryKit

/// Manages access and refresh tokens with thread-safe access via an actor.
actor TokenManager {
    
    private let accessTokenKey = "com.app.accessToken"
    private let refreshTokenKey = "com.app.refreshToken"
    
    @Injected(\.userDefaultsService)
    var userDefaults: UserDefaultsServiceType
    
    // MARK: - Access Token
    
    var accessToken: String? {
        userDefaults.string(forKey: accessTokenKey)
    }
    
    func setAccessToken(_ token: String?) {
        userDefaults.set(token, forKey: accessTokenKey)
    }
    
    // MARK: - Refresh Token
    
    var refreshToken: String? {
        userDefaults.string(forKey: refreshTokenKey)
    }
    
    func setRefreshToken(_ token: String?) {
        userDefaults.set(token, forKey: refreshTokenKey)
    }
    
    // MARK: - Convenience
    
    func updateTokens(accessToken: String, refreshToken: String) {
        setAccessToken(accessToken)
        setRefreshToken(refreshToken)
    }
    
    func clearTokens() {
        setAccessToken(nil)
        setRefreshToken(nil)
    }
    
    var hasValidToken: Bool {
        accessToken != nil && !(accessToken?.isEmpty ?? true)
    }
}
