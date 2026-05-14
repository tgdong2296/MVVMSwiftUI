//
//  MockAuthUseCase.swift
//  MVVMSwiftUITests
//

import Foundation
@testable import MVVMSwiftUI

@MainActor
final class MockAuthUseCase: AuthUseCaseType {

    var loginError: Error?
    var registerError: Error?
    var requestOTPError: Error?
    var verifyOTPError: Error?
    var resetPasswordError: Error?

    private(set) var loginCallCount = 0
    private(set) var registerCallCount = 0
    private(set) var requestOTPCallCount = 0
    private(set) var verifyOTPCallCount = 0
    private(set) var resetPasswordCallCount = 0

    private(set) var capturedLoginEmail: String?
    private(set) var capturedLoginPassword: String?
    private(set) var capturedRegisterName: String?
    private(set) var capturedRegisterEmail: String?
    private(set) var capturedOTPEmail: String?
    private(set) var capturedVerifyOTPEmail: String?
    private(set) var capturedVerifyOTP: String?
    private(set) var capturedResetEmail: String?
    private(set) var capturedResetOTP: String?
    private(set) var capturedNewPassword: String?

    func login(email: String, password: String) async throws {
        loginCallCount += 1
        capturedLoginEmail = email
        capturedLoginPassword = password
        if let error = loginError { throw error }
    }

    func register(name: String, email: String, password: String) async throws {
        registerCallCount += 1
        capturedRegisterName = name
        capturedRegisterEmail = email
        if let error = registerError { throw error }
    }

    func requestOTP(email: String) async throws {
        requestOTPCallCount += 1
        capturedOTPEmail = email
        if let error = requestOTPError { throw error }
    }

    func verifyOTP(email: String, otp: String) async throws {
        verifyOTPCallCount += 1
        capturedVerifyOTPEmail = email
        capturedVerifyOTP = otp
        if let error = verifyOTPError { throw error }
    }

    func resetPassword(email: String, otp: String, newPassword: String) async throws {
        resetPasswordCallCount += 1
        capturedResetEmail = email
        capturedResetOTP = otp
        capturedNewPassword = newPassword
        if let error = resetPasswordError { throw error }
    }
}
