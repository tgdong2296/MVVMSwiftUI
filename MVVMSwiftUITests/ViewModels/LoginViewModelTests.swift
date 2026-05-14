//
//  LoginViewModelTests.swift
//  MVVMSwiftUITests
//

import Testing
import FactoryKit
@testable import MVVMSwiftUI

@Suite("LoginViewModel")
@MainActor
struct LoginViewModelTests {

    let mockUseCase: MockAuthUseCase
    let sut: LoginViewModel

    init() {
        Container.shared.reset()
        mockUseCase = MockAuthUseCase()
        Container.shared.authUseCase.register { [mockUseCase] in mockUseCase }
        sut = LoginViewModel()
    }

    // MARK: - Initial State

    @Test("isLoading starts as false")
    func initialState() {
        #expect(sut.isLoading == false)
    }

    // MARK: - Login Success

    @Test("Login success calls use case with correct credentials")
    func loginSuccessCallsUseCase() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")

        #expect(mockUseCase.loginCallCount == 1)
        #expect(mockUseCase.capturedLoginEmail == "user@example.com")
        #expect(mockUseCase.capturedLoginPassword == "Password1")
    }

    @Test("isLoading is false after successful login")
    func isLoadingFalseAfterSuccess() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")
        #expect(sut.isLoading == false)
    }

    // MARK: - Login Failure

    @Test("Login failure rethrows the error")
    func loginFailureRethrows() async {
        mockUseCase.loginError = TestError.mock
        var caughtError: Error?

        do {
            try await sut.login(email: "user@example.com", password: "wrong")
        } catch {
            caughtError = error
        }

        #expect(caughtError is TestError)
    }

    @Test("isLoading is false after failed login")
    func isLoadingFalseAfterFailure() async {
        mockUseCase.loginError = TestError.mock
        try? await sut.login(email: "user@example.com", password: "wrong")
        #expect(sut.isLoading == false)
    }

    @Test("Login is not called more than once per invocation")
    func loginCalledOnce() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")
        #expect(mockUseCase.loginCallCount == 1)
    }
}
