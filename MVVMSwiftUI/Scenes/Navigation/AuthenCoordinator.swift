//
//  AuthenCoordinator.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI
import FactoryKit

enum AuthenRoute: Route {
    case register
    case resetPassword
    case verifyOTP
    case newPassword
    
    var id: AuthenRoute { self }
}

@Observable
final class AuthenCoordinator {
    var path: [AuthenRoute] = []
    
    func goBack() {
        path.removeLast()
    }
    
    func toRegister() {
        path.append(.register)
    }
    
    func toResetPassword() {
        path.append(.resetPassword)
    }
    
    func toVerifyOTP() {
        path.append(.verifyOTP)
    }
    
    func toNewPassword() {
        path.append(.newPassword)
    }
    
    func backToRoot() {
        path.removeAll()
    }
}

// MARK: - Coordinator
extension AuthenCoordinator: CoordinatorType {
    
    @ViewBuilder
    func rootView() -> some View {
        Container.shared.loginView().resolve()
    }
    
    @ViewBuilder
    func redirect(_ path: AuthenRoute) -> some View {
        switch path {
        case .register:
            Container.shared.registerView().resolve()
        case .resetPassword:
            Container.shared.enterEmailView().resolve()
        case .verifyOTP:
            Container.shared.verifyOTPView().resolve()
        case .newPassword:
            Container.shared.newPasswordView().resolve()
        }
    }
}

extension Container {
    
    var authenCoordinator: Factory<AuthenCoordinator> {
        Factory(self) { @MainActor in
            AuthenCoordinator()
        }
    }
}
