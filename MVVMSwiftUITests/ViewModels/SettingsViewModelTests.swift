//
//  SettingsViewModelTests.swift
//  MVVMSwiftUITests
//

import Testing
import FactoryKit
@testable import MVVMSwiftUI

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    let mockUseCase: MockAuthUseCase
    let sut: SettingsViewModel

    init() {
        Container.shared.reset()
        mockUseCase = MockAuthUseCase()
        Container.shared.authUseCase.register { [mockUseCase] in mockUseCase }
        sut = SettingsViewModel()
    }

    // MARK: - Initial State

    @Test("viewState starts as indie")
    func initialState() {
        #expect(sut.viewState == .indie)
    }

    // MARK: - Logout Success

    @Test("Logout calls the auth use case once")
    func logoutCallsUseCase() async {
        await sut.logout()
        #expect(mockUseCase.logoutCallCount == 1)
    }

    @Test("viewState is success after successful logout")
    func successStateAfterLogout() async {
        await sut.logout()
        #expect(sut.viewState == .success)
    }

    // MARK: - Logout Failure

    @Test("Logout failure sets error state")
    func logoutFailureSetsErrorState() async {
        mockUseCase.logoutError = TestError.mock
        await sut.logout()

        if case .error = sut.viewState {
            // expected
        } else {
            Issue.record("Expected viewState to be .error, got \(sut.viewState)")
        }
    }
}
