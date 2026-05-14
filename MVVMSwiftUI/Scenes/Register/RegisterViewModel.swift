//
//  RegisterViewModel.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class RegisterViewModel {

    // MARK: - Dependencies

    @Injected(\.authUseCase)
    @ObservationIgnored private var authUseCase

    // MARK: - State

    var isLoading: Bool = false

    // MARK: - Actions

    func register(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        try await authUseCase.register(name: "", email: email, password: password)
    }
}

// MARK: - Factory Registration

extension Container {

    var registerViewModel: Factory<RegisterViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                RegisterViewModel()
            }
        }
    }
}
