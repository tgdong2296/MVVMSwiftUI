//
//  AuthenticationManager.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI
import FactoryKit

protocol AuthenStoreType: AgreegateType {
    
    var flow: AppFlow { get }
    
    var isLoading: Bool { get }
    
    var isAuthenticated: Bool { get }
    
    func loggedIn() async throws
    
    func loggedOut() async throws
}

@Observable
@MainActor
final class AuthenStore: AuthenStoreType {
    // MARK: - State
    private(set) var state: ViewState = .indie
    
    private(set) var flow: AppFlow = .notAuthenticated
    
    private(set) var resetEmail: String = ""
    
    private(set) var resetOTP: String = ""
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        state == .loading
    }
    
    var isAuthenticated: Bool {
        flow == .authenticated
    }
    
    // MARK: - Actions
    func loggedIn() async throws {
        state = .loading
        
        try await Task.sleep(for: .seconds(1))
        flow = .authenticated
        
        state = .success
    }
    
    func loggedOut() async throws {
        state = .loading
        
        try await Task.sleep(for: .seconds(1))
        flow = .notAuthenticated
        
        state = .success
    }
}

extension Container {
    var authenStore: Factory<AuthenStoreType> {
        Factory(self) { @MainActor in
            AuthenStore()
        }
        .singleton
    }
}
