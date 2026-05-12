//
//  NewPasswordView.swift
//  VMPatternSwiftUI
//

import SwiftUI
import FactoryKit

struct NewPasswordView: View {

    @Environment(AuthenCoordinator.self)
    var authenCoordinator

    @Environment(ThemeStore.self)
    private var themeStore

    @State var viewModel: ResetPasswordViewModel

    @State private var showSuccessAlert = false

    @Validate(name: "password", autoValidate: true, .isPassword())
    var password: String = ""

    @Validate(name: "confirmPassword", autoValidate: true, .isNotEmpty(message: "Please confirm your password"))
    var confirmPassword: String = ""

    private var isPasswordMatching: Bool {
        password == confirmPassword
    }

    private var isFormValid: Bool {
        _password.isValid && _confirmPassword.isValid && isPasswordMatching
    }

    private var isSubmitDisabled: Bool {
        !isFormValid || viewModel.isLoading
    }

    private var confirmPasswordValidationState: ValidationState {
        guard !confirmPassword.isEmpty else { return .idle }
        return isPasswordMatching ? .valid : .invalid(messages: ["Passwords do not match"])
    }

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(spacing: 16) {
                headerView
                passwordField
                confirmPasswordField
            }

            resetButton
        }
        .padding(.horizontal, 24)
        .navigationTitle("New Password")
        .onChange(of: viewModel.resetStep) { _, newStep in
            if newStep == .completed {
                showSuccessAlert = true
            }
        }
        .alert("Password Reset", isPresented: $showSuccessAlert) {
            Button("OK") {
                viewModel.clearResetState()
                authenCoordinator.backToRoot()
            }
        } message: {
            Text("Your password has been reset successfully.")
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Create new password")
                .font(.title2)
                .fontWeight(.bold)

            Text("Enter your new password below.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
    }

    private var passwordField: some View {
        SecureField("Enter new password", text: $password)
            .textContentType(.newPassword)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(_password.validationState)
    }

    private var confirmPasswordField: some View {
        SecureField("Confirm new password", text: $confirmPassword)
            .textContentType(.newPassword)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(confirmPasswordValidationState)
    }

    private var resetButton: some View {
        Button {
            Task {
                await viewModel.resetPassword(newPassword: password)
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Reset Password")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSubmitDisabled ? themeStore.disabledColor : themeStore.primaryColor)
            .foregroundStyle(themeStore.onPrimaryColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isSubmitDisabled)
    }
}

// MARK: - Factory Registration

extension Container {

    func newPasswordView() -> Factory<NewPasswordView> {
        Factory(self) { @MainActor in
            NewPasswordView(viewModel: self.resetPasswordViewModel())
        }
    }
}

#Preview {
    NavigationStack {
        NewPasswordView(viewModel: Container.shared.resetPasswordViewModel())
            .environment(Container.shared.themeStore.resolve())
            .environment(Container.shared.authenCoordinator.resolve())
    }
}
