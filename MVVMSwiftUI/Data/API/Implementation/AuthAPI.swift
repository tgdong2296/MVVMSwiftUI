//
//  AuthAPI.swift
//  MVVMSwiftUI
//

import Foundation
@preconcurrency import Moya
import FactoryKit
import Alamofire

// MARK: - API Target Definition

enum AuthAPI: BaseTargetType, Sendable {
    case login(email: String, password: String)
    case logout
    case register(name: String, email: String, password: String)
    case requestOTP(email: String)
    case verifyOTP(email: String, otp: String)
    case resetPassword(email: String, otp: String, newPassword: String)

    nonisolated var requiresAuth: Bool {
        switch self {
        case .login, .register, .requestOTP, .verifyOTP, .resetPassword:
            return false
        default:
            return true
        }
    }

    nonisolated var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .logout:
            return "auth/logout"
        case .register:
            return "/auth/register"
        case .requestOTP:
            return "/auth/otp/request"
        case .verifyOTP:
            return "/auth/otp/verify"
        case .resetPassword:
            return "/auth/password/reset"
        }
    }

    nonisolated var method: Moya.Method {
        return .post
    }

    nonisolated var task: Moya.Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case .logout:
            return .requestPlain
        case let .register(name, email, password):
            return .requestParameters(
                parameters: ["name": name, "email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case .requestOTP(let email):
            return .requestParameters(
                parameters: ["email": email],
                encoding: JSONEncoding.default
            )
        case let .verifyOTP(email, otp):
            return .requestParameters(
                parameters: ["email": email, "otp": otp],
                encoding: JSONEncoding.default
            )
        case let .resetPassword(email, otp, newPassword):
            return .requestParameters(
                parameters: ["email": email, "otp": otp, "newPassword": newPassword],
                encoding: JSONEncoding.default
            )
        }
    }

    nonisolated var sampleData: Data {
        switch self {
        case .login:
            return MockHelper.loadJSON(from: "login")
        case .logout:
            return Data()
        case .register:
            return MockHelper.loadJSON(from: "register")
        case .requestOTP:
            return MockHelper.loadJSON(from: "request_otp")
        case .verifyOTP:
            return MockHelper.loadJSON(from: "verify_otp")
        case .resetPassword:
            return MockHelper.loadJSON(from: "reset_password")
        }
    }
}

// MARK: - DI Registration

extension Container {
    var authApiService: Factory<APIService<AuthAPI>> {
        Factory(self) {
            MainActor.assumeIsolated {
                let provider = MoyaProvider<AuthAPI>(stubClosure: MoyaProvider.delayedStub(0.5))
                return APIService(
                    provider: provider,
                    tokenManager: self.tokenManager(),
                    refreshCoordinator: self.tokenRefreshCoordinator()
                )
            }
        }
        .singleton
    }
}
