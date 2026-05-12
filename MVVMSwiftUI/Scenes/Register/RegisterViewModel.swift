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

    @ObservationIgnored
    @Injected(\.authApiService)
    private var authService

    // MARK: - State

    var isLoading: Bool = false

    // MARK: - Actions

    func register(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        _ = try await authService.requestWrapped(
            .register(name: "", email: email, password: password),
            type: EmptyResponse.self
        )
    }
}

// MARK: - Factory Registration

extension Container {

    var registerViewModel: Factory<RegisterViewModel> {
        Factory(self) { @MainActor in
            RegisterViewModel()
        }
    }
}
