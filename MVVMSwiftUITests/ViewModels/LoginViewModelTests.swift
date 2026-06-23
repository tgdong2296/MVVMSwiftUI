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

    @Test("viewState starts as indie")
    func initialState() {
        #expect(sut.viewState == .indie)
    }

    // MARK: - Login Success

    @Test("Login success calls use case with correct credentials")
    func loginSuccessCallsUseCase() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")

        #expect(mockUseCase.loginCallCount == 1)
        #expect(mockUseCase.capturedLoginEmail == "user@example.com")
        #expect(mockUseCase.capturedLoginPassword == "Password1")
    }

    @Test("viewState is success after successful login")
    func successStateAfterSuccess() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")
        #expect(sut.viewState == .success)
    }

    // MARK: - Login Failure

    @Test("Login failure sets error state")
    func loginFailureSetsErrorState() async throws {
        mockUseCase.loginError = TestError.mock
        try await sut.login(email: "user@example.com", password: "wrong")

        if case .error = sut.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .error, got \(sut.viewState)")
        }
    }

    @Test("viewState is not loading after failed login")
    func notLoadingAfterFailure() async throws {
        mockUseCase.loginError = TestError.mock
        try await sut.login(email: "user@example.com", password: "wrong")
        #expect(sut.viewState != .loading)
    }

    @Test("Login is not called more than once per invocation")
    func loginCalledOnce() async throws {
        try await sut.login(email: "user@example.com", password: "Password1")
        #expect(mockUseCase.loginCallCount == 1)
    }
}
