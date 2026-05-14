//
//  AuthenticationManager.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI
import FactoryKit

protocol AuthenStoreType {
    
    var flow: AppFlow { get set }
    
    var isAuthenticated: Bool { get }
}

@Observable
@MainActor
final class AuthenStore: AuthenStoreType {
    // MARK: - State
    var flow: AppFlow = .notAuthenticated
    
    // MARK: - Computed Properties
    var isAuthenticated: Bool {
        flow == .authenticated
    }
}

extension Container {
    var authenStore: Factory<AuthenStoreType> {
        Factory(self) {
            MainActor.assumeIsolated {
                AuthenStore()
            }
        }
        .singleton
    }
}
