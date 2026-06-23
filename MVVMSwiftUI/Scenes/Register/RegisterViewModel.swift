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

    var viewState: ViewState = .indie

    // MARK: - Actions

    func register(email: String, password: String) async throws {
        guard viewState != .loading else { return }
        viewState = .loading
        do {
            try await authUseCase.register(name: "", email: email, password: password)
            viewState = .success
        } catch {
            viewState = .error([error.localizedDescription])
        }
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
