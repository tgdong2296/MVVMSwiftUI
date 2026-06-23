//
//  AuthUseCase.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

// MARK: - Protocol

@MainActor
protocol AuthUseCaseType: AnyObject {
    func login(email: String, password: String) async throws
    func logout() async throws
    func register(name: String, email: String, password: String) async throws
    func requestOTP(email: String) async throws
    func verifyOTP(email: String, otp: String) async throws
    func resetPassword(email: String, otp: String, newPassword: String) async throws
}

// MARK: - Implementation

@MainActor
final class AuthUseCase: AuthUseCaseType {

    @Injected(\.authApiService)
    private var authService
    
    @Injected(\.appStateStore)
    private var appStateStore

    func login(email: String, password: String) async throws {
        _ = try await authService.requestWrapped(
            .login(email: email, password: password),
            type: EmptyResponse.self
        )
        appStateStore.update(.authenticated)
    }
    
    func logout() async throws {
        _ = try await authService.requestVoid(.logout)
        appStateStore.update(.notAuthenticated)
    }

    func register(name: String, email: String, password: String) async throws {
        _ = try await authService.requestWrapped(
            .register(name: name, email: email, password: password),
            type: EmptyResponse.self
        )
    }

    func requestOTP(email: String) async throws {
        _ = try await authService.requestWrapped(
            .requestOTP(email: email),
            type: EmptyResponse.self
        )
    }

    func verifyOTP(email: String, otp: String) async throws {
        _ = try await authService.requestWrapped(
            .verifyOTP(email: email, otp: otp),
            type: EmptyResponse.self
        )
    }

    func resetPassword(email: String, otp: String, newPassword: String) async throws {
        _ = try await authService.requestWrapped(
            .resetPassword(email: email, otp: otp, newPassword: newPassword),
            type: EmptyResponse.self
        )
    }
}

// MARK: - DI Registration

extension Container {
    var authUseCase: Factory<AuthUseCaseType> {
        Factory(self) {
            MainActor.assumeIsolated {
                AuthUseCase()
            }
        }
        .singleton
    }
}
