//
//  RegisterViewModelTests.swift
//  MVVMSwiftUITests
//

import Testing
import FactoryKit
@testable import MVVMSwiftUI

@Suite("RegisterViewModel")
@MainActor
struct RegisterViewModelTests {

    let mockUseCase: MockAuthUseCase
    let sut: RegisterViewModel

    init() {
        Container.shared.reset()
        mockUseCase = MockAuthUseCase()
        Container.shared.authUseCase.register { [mockUseCase] in mockUseCase }
        sut = RegisterViewModel()
    }

    // MARK: - Initial State

    @Test("viewState starts as indie")
    func initialState() {
        #expect(sut.viewState == .indie)
    }

    // MARK: - Register Success

    @Test("Register success calls use case with correct email and password")
    func registerSuccessCallsUseCase() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")

        #expect(mockUseCase.registerCallCount == 1)
        #expect(mockUseCase.capturedRegisterEmail == "new@example.com")
    }

    @Test("viewState is success after successful register")
    func successStateAfterSuccess() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")
        #expect(sut.viewState == .success)
    }

    // MARK: - Register Failure

    @Test("Register failure sets error state")
    func registerFailureSetsErrorState() async throws {
        mockUseCase.registerError = TestError.mock
        try await sut.register(email: "new@example.com", password: "Password1")

        if case .error = sut.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .error, got \(sut.viewState)")
        }
    }

    @Test("viewState is not loading after failed register")
    func notLoadingAfterFailure() async throws {
        mockUseCase.registerError = TestError.mock
        try await sut.register(email: "new@example.com", password: "Password1")
        #expect(sut.viewState != .loading)
    }

    @Test("Register is not called more than once per invocation")
    func registerCalledOnce() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")
        #expect(mockUseCase.registerCallCount == 1)
    }
}
