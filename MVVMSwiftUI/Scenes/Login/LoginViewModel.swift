//
//  LoginViewModel.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class LoginViewModel {

    // MARK: - Dependencies

    @ObservationIgnored
    @Injected(\.authenStore) private var authenStore

    // MARK: - State

    var isLoading: Bool = false

    // MARK: - Actions

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await authenStore.loggedIn()
    }
}

// MARK: - Factory Registration

extension Container {

    var loginViewModel: Factory<LoginViewModel> {
        Factory(self) { @MainActor in
            LoginViewModel()
        }
    }
}
