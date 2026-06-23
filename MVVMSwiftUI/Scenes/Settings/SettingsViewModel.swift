//
//  SettingsViewModel.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class SettingsViewModel {

    // MARK: - Dependencies

    @Injected(\.authUseCase)
    @ObservationIgnored private var authUseCase

    // MARK: - State

    var viewState: ViewState = .indie

    // MARK: - Actions

    func logout() async {
        guard viewState != .loading else { return }
        viewState = .loading
        do {
            try await authUseCase.logout()
            viewState = .success
        } catch {
            viewState = .error([error.localizedDescription])
        }
    }
}

// MARK: - Factory Registration

extension Container {

    var settingsViewModel: Factory<SettingsViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                SettingsViewModel()
            }
        }
    }
}
