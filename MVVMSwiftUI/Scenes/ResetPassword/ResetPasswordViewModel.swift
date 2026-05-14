//
//  ResetPasswordViewModel.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class ResetPasswordViewModel {

    // MARK: - Reset Step

    enum ResetStep: Equatable {
        case initial
        case otpSent
        case otpVerified
        case completed
    }

    // MARK: - Dependencies

    @Injected(\.authUseCase)
    @ObservationIgnored private var authUseCase

    // MARK: - State

    var viewState: ViewState = .indie
    var resetStep: ResetStep = .initial
    private(set) var resetEmail: String = ""

    var isLoading: Bool { viewState == .loading }

    // MARK: - Actions

    func requestOTP(email: String) async {
        viewState = .loading
        do {
            try await authUseCase.requestOTP(email: email)
            resetEmail = email
            resetStep = .otpSent
            viewState = .success
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func verifyOTP(otp: String) async {
        viewState = .loading
        do {
            try await authUseCase.verifyOTP(email: resetEmail, otp: otp)
            resetStep = .otpVerified
            viewState = .success
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func resetPassword(newPassword: String) async {
        viewState = .loading
        do {
            try await authUseCase.resetPassword(email: resetEmail, otp: "", newPassword: newPassword)
            resetStep = .completed
            viewState = .success
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func clearResetState() {
        resetStep = .initial
        resetEmail = ""
    }
}

// MARK: - Factory Registration

extension Container {

    var resetPasswordViewModel: Factory<ResetPasswordViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                ResetPasswordViewModel()
            }
        }
        .singleton
    }
}
