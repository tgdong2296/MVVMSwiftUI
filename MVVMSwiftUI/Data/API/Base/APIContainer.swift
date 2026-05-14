//
//  APIContainer.swift
//  VMPatternSwiftUI
//

import Foundation
import FactoryKit
@preconcurrency import Moya

extension Container {
    
    var tokenManager: Factory<TokenManager> {
        Factory(self) {
            TokenManager()
        }
        .singleton
    }
    
    var tokenRefreshCoordinator: Factory<TokenRefreshCoordinator> {
        Factory(self) {
            MainActor.assumeIsolated {
                TokenRefreshCoordinator(provider: MoyaProvider<AuthTarget>())
            }
        }
        .singleton
    }
    
    /// Creates an `APIService` for the given `BaseTargetType`.
    /// In DEV mode with mock enabled, it uses stubbed JSON responses.
    @MainActor
    func apiService<T: BaseTargetType>(stubMapping: ((T) -> String)? = nil) -> APIService<T> {
        let tokenManager = self.tokenManager()
        let refreshCoordinator = self.tokenRefreshCoordinator()
        
        let accessTokenPlugin = AccessTokenPlugin { _ in
            // AccessTokenPlugin's tokenClosure is synchronous,
            // so we read directly from UserDefaults (which is thread-safe for reads).
            UserDefaults.standard.string(forKey: "com.app.accessToken") ?? ""
        }
        
        let moyaProvider: MoyaProvider<T>
        
        if Environments.isDEV, let mapping = stubMapping {
            moyaProvider = MockHelper.stubbedProvider(mapping: mapping)
        } else {
            moyaProvider = MoyaProvider<T>(
                plugins: [
                    accessTokenPlugin,
                    NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
                ]
            )
        }
        
        return APIService(
            provider: moyaProvider,
            tokenManager: tokenManager,
            refreshCoordinator: refreshCoordinator
        )
    }
}
