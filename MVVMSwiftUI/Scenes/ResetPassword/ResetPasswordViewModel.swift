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

    @ObservationIgnored
    @Injected(\.authApiService)
    private var authService

    // MARK: - State

    var isLoading: Bool = false
    var resetStep: ResetStep = .initial
    private(set) var resetEmail: String = ""

    // MARK: - Actions

    func requestOTP(email: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.requestWrapped(
                .requestOTP(email: email),
                type: EmptyResponse.self
            )
            resetEmail = email
            resetStep = .otpSent
        } catch {
            // Error handling can be expanded as needed
        }
    }

    func verifyOTP(otp: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.requestWrapped(
                .verifyOTP(email: resetEmail, otp: otp),
                type: EmptyResponse.self
            )
            resetStep = .otpVerified
        } catch {
            // Error handling can be expanded as needed
        }
    }

    func resetPassword(newPassword: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await authService.requestWrapped(
                .resetPassword(email: resetEmail, otp: "", newPassword: newPassword),
                type: EmptyResponse.self
            )
            resetStep = .completed
        } catch {
            // Error handling can be expanded as needed
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
        Factory(self) { @MainActor in
            ResetPasswordViewModel()
        }
        .singleton
    }
}
