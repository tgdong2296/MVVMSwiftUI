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

    @Injected(\.authUseCase)
    @ObservationIgnored private var authUseCase

    // MARK: - State

    var isLoading: Bool = false

    // MARK: - Actions

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try await authUseCase.login(email: email, password: password)
    }
}

// MARK: - Factory Registration

extension Container {

    var loginViewModel: Factory<LoginViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                LoginViewModel()
            }
        }
    }
}
