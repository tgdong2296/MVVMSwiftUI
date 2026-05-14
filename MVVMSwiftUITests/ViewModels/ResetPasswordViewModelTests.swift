//
//  ResetPasswordViewModelTests.swift
//  MVVMSwiftUITests
//

import Testing
import FactoryKit
@testable import MVVMSwiftUI

@Suite("ResetPasswordViewModel")
@MainActor
struct ResetPasswordViewModelTests {

    let mockUseCase: MockAuthUseCase
    let sut: ResetPasswordViewModel

    init() {
        Container.shared.reset()
        mockUseCase = MockAuthUseCase()
        Container.shared.authUseCase.register { [mockUseCase] in mockUseCase }
        sut = ResetPasswordViewModel()
    }

    // MARK: - Initial State

    @Test("Initial state is indie, initial step, no email stored")
    func initialState() {
        #expect(sut.viewState == .indie)
        #expect(sut.resetStep == .initial)
        #expect(sut.isLoading == false)
    }

    // MARK: - Request OTP

    @Test("requestOTP success transitions to otpSent and stores email")
    func requestOTPSuccess() async {
        await sut.requestOTP(email: "user@example.com")

        #expect(sut.resetStep == .otpSent)
        #expect(sut.viewState == .success)
        #expect(sut.resetEmail == "user@example.com")
    }

    @Test("requestOTP success calls use case with correct email")
    func requestOTPCallsUseCase() async {
        await sut.requestOTP(email: "user@example.com")

        #expect(mockUseCase.requestOTPCallCount == 1)
        #expect(mockUseCase.capturedOTPEmail == "user@example.com")
    }

    @Test("requestOTP failure sets error viewState and keeps step at initial")
    func requestOTPFailure() async {
        mockUseCase.requestOTPError = TestError.mock

        await sut.requestOTP(email: "user@example.com")

        if case .error(let message) = sut.viewState {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Expected .error viewState, got \(sut.viewState)")
        }
        #expect(sut.resetStep == .initial)
    }

    @Test("isLoading reflects loading viewState")
    func isLoadingReflectsViewState() {
        #expect(sut.isLoading == false)
    }

    // MARK: - Verify OTP

    @Test("verifyOTP success transitions to otpVerified")
    func verifyOTPSuccess() async {
        // First get to otpSent state
        await sut.requestOTP(email: "user@example.com")

        await sut.verifyOTP(otp: "123456")

        #expect(sut.resetStep == .otpVerified)
        #expect(sut.viewState == .success)
    }

    @Test("verifyOTP passes stored email and provided OTP to use case")
    func verifyOTPCallsUseCase() async {
        await sut.requestOTP(email: "user@example.com")
        await sut.verifyOTP(otp: "123456")

        #expect(mockUseCase.capturedVerifyOTPEmail == "user@example.com")
        #expect(mockUseCase.capturedVerifyOTP == "123456")
    }

    @Test("verifyOTP failure sets error viewState and keeps step at otpSent")
    func verifyOTPFailure() async {
        await sut.requestOTP(email: "user@example.com")
        mockUseCase.verifyOTPError = TestError.mock

        await sut.verifyOTP(otp: "wrong")

        if case .error(let message) = sut.viewState {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Expected .error viewState, got \(sut.viewState)")
        }
        #expect(sut.resetStep == .otpSent)
    }

    // MARK: - Reset Password

    @Test("resetPassword success transitions to completed")
    func resetPasswordSuccess() async {
        await sut.requestOTP(email: "user@example.com")
        await sut.verifyOTP(otp: "123456")

        await sut.resetPassword(newPassword: "NewPassword1")

        #expect(sut.resetStep == .completed)
        #expect(sut.viewState == .success)
    }

    @Test("resetPassword passes stored email and new password to use case")
    func resetPasswordCallsUseCase() async {
        await sut.requestOTP(email: "user@example.com")
        await sut.verifyOTP(otp: "123456")

        await sut.resetPassword(newPassword: "NewPassword1")

        #expect(mockUseCase.capturedResetEmail == "user@example.com")
        #expect(mockUseCase.capturedNewPassword == "NewPassword1")
    }

    @Test("resetPassword failure sets error viewState and keeps step at otpVerified")
    func resetPasswordFailure() async {
        await sut.requestOTP(email: "user@example.com")
        await sut.verifyOTP(otp: "123456")
        mockUseCase.resetPasswordError = TestError.mock

        await sut.resetPassword(newPassword: "NewPassword1")

        if case .error(let message) = sut.viewState {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Expected .error viewState, got \(sut.viewState)")
        }
        #expect(sut.resetStep == .otpVerified)
    }

    // MARK: - Clear State

    @Test("clearResetState resets step to initial and clears email")
    func clearResetState() async {
        await sut.requestOTP(email: "user@example.com")

        sut.clearResetState()

        #expect(sut.resetStep == .initial)
        #expect(sut.resetEmail.isEmpty)
    }

    // MARK: - Full Flow

    @Test("Full reset password flow transitions through all steps")
    func fullFlow() async {
        #expect(sut.resetStep == .initial)

        await sut.requestOTP(email: "user@example.com")
        #expect(sut.resetStep == .otpSent)

        await sut.verifyOTP(otp: "123456")
        #expect(sut.resetStep == .otpVerified)

        await sut.resetPassword(newPassword: "NewPassword1")
        #expect(sut.resetStep == .completed)
    }
}
