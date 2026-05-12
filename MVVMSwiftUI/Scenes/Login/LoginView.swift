//
//  LoginView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI
import FactoryKit

struct LoginView: View {
    
    @Environment(AuthenCoordinator.self)
    var authenCoordinator
    
    @Environment(ThemeStore.self)
    private var themeStore
    
    @State var viewModel: LoginViewModel
    
    @Validate(name: "email", autoValidate: true, .isEmail())
    var email: String = ""
    
    @Validate(name: "password", autoValidate: true, .isPassword())
    var password: String = ""
    
    private var isFormValid: Bool {
        _email.isValid && _password.isValid
    }
    
    private var isLoginDisabled: Bool {
        !isFormValid || viewModel.isLoading
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            
            // Form Fields
            VStack(spacing: 16) {
                headerView
                emailField
                passwordField
            }
            
            // Login Button
            loginButton
            
            // Forgot Password
            Button {
                authenCoordinator.toResetPassword()
            } label: {
                Text("Forgot Password?")
                    .font(.subheadline)
                    .foregroundStyle(themeStore.primaryColor)
            }
            
            // Register Link
            Button {
                authenCoordinator.toRegister()
            } label: {
                HStack(spacing: 3) {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Text("Register")
                        .foregroundStyle(themeStore.primaryColor)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Login")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 32)
        }
    }
    
    private var emailField: some View {
        TextField("Enter your email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(_email.validationState)
    }
    
    private var passwordField: some View {
        SecureField("Enter your password", text: $password)
            .textContentType(.password)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(_password.validationState)
    }
    
    private var loginButton: some View {
        Button {
            Task {
                try await viewModel.login(email: email, password: password)
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoginDisabled ? themeStore.disabledColor : themeStore.primaryColor)
            .foregroundStyle(themeStore.onPrimaryColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoginDisabled)
    }
}

// MARK: - Factory Registration
extension Container {
    
    func loginView() -> Factory<LoginView> {
        Factory(self) { @MainActor in
            LoginView(viewModel: self.loginViewModel())
        }
    }
}

#Preview {
    CoordinatorNavigationView(coordinator: Container.shared.authenCoordinator.resolve())
        .environment(Container.shared.themeStore.resolve())
}
