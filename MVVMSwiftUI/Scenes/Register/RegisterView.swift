//
//  RegisterView.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 3/26/26.
//

import SwiftUI
import FactoryKit

struct RegisterView: View {
    
    @State var viewModel: RegisterViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(ThemeStore.self)
    private var themeStore
    
    @Validate(name: "email", autoValidate: true, .isEmail())
    var email: String = ""
    
    @Validate(name: "password", autoValidate: true, .isPassword())
    var password: String = ""
    
    @Validate(name: "confirmPassword", autoValidate: true, .isNotEmpty(message: "Please confirm your password"))
    var confirmPassword: String = ""
    
    private var isPasswordMatching: Bool {
        password == confirmPassword
    }
    
    private var isFormValid: Bool {
        _email.isValid && _password.isValid && _confirmPassword.isValid && isPasswordMatching
    }
    
    private var isRegisterDisabled: Bool {
        !isFormValid || viewModel.viewState == .loading
    }
    
    private var confirmPasswordValidationState: ValidationState {
        guard !confirmPassword.isEmpty else { return .idle }
        return isPasswordMatching ? .valid : .invalid(messages: ["Passwords do not match"])
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(spacing: 16) {
                headerView
                emailField
                passwordField
                confirmPasswordField
            }
            .padding(.top, 160)
            
            Spacer()
            
            // Register Button
            registerButton
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                Text("Register")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 32)
            }
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
            .textContentType(.newPassword)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(_password.validationState)
    }
    
    private var confirmPasswordField: some View {
        SecureField("Re-enter your password", text: $confirmPassword)
            .textContentType(.newPassword)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(confirmPasswordValidationState)
    }
    
    private var registerButton: some View {
        Button {
            Task {
                try await viewModel.register(email: email, password: password)
            }
        } label: {
            Group {
                if viewModel.viewState == .loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Register")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isRegisterDisabled ? themeStore.disabledColor : themeStore.primaryColor)
            .foregroundStyle(themeStore.onPrimaryColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isRegisterDisabled)
    }
}

// MARK: - Factory Registration
extension Container {
    
    func registerView() -> Factory<RegisterView> {
        Factory(self) {
            MainActor.assumeIsolated {
                RegisterView(viewModel: self.registerViewModel())
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: Container.shared.registerViewModel())
            .environment(Container.shared.themeStore.resolve())
    }
}
