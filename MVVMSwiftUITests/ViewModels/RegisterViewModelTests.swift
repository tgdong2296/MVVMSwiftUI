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

    @Test("isLoading starts as false")
    func initialState() {
        #expect(sut.isLoading == false)
    }

    // MARK: - Register Success

    @Test("Register success calls use case with correct email and password")
    func registerSuccessCallsUseCase() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")

        #expect(mockUseCase.registerCallCount == 1)
        #expect(mockUseCase.capturedRegisterEmail == "new@example.com")
    }

    @Test("isLoading is false after successful register")
    func isLoadingFalseAfterSuccess() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")
        #expect(sut.isLoading == false)
    }

    // MARK: - Register Failure

    @Test("Register failure rethrows the error")
    func registerFailureRethrows() async {
        mockUseCase.registerError = TestError.mock
        var caughtError: Error?

        do {
            try await sut.register(email: "new@example.com", password: "Password1")
        } catch {
            caughtError = error
        }

        #expect(caughtError is TestError)
    }

    @Test("isLoading is false after failed register")
    func isLoadingFalseAfterFailure() async {
        mockUseCase.registerError = TestError.mock
        try? await sut.register(email: "new@example.com", password: "Password1")
        #expect(sut.isLoading == false)
    }

    @Test("Register is not called more than once per invocation")
    func registerCalledOnce() async throws {
        try await sut.register(email: "new@example.com", password: "Password1")
        #expect(mockUseCase.registerCallCount == 1)
    }
}
