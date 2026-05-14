//
//  EnterEmailView.swift
//  VMPatternSwiftUI
//

import SwiftUI
import FactoryKit

struct EnterEmailView: View {

    @Environment(AuthenCoordinator.self)
    var authenCoordinator

    @Environment(ThemeStore.self)
    private var themeStore

    @State var viewModel: ResetPasswordViewModel

    @Validate(name: "email", autoValidate: true, .isEmail())
    var email: String = ""

    private var isFormValid: Bool {
        _email.isValid
    }

    private var isSubmitDisabled: Bool {
        !isFormValid || viewModel.isLoading
    }

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(spacing: 16) {
                headerView
                emailField
            }

            submitButton
        }
        .padding(.horizontal, 24)
        .navigationTitle("Reset Password")
        .onChange(of: viewModel.resetStep) { _, newStep in
            if newStep == .otpSent {
                authenCoordinator.toVerifyOTP()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Enter your email")
                .font(.title2)
                .fontWeight(.bold)

            Text("We'll send a verification code to your email address.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
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

    private var submitButton: some View {
        Button {
            Task {
                await viewModel.requestOTP(email: email)
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Send OTP")
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

    func enterEmailView() -> Factory<EnterEmailView> {
        Factory(self) {
            MainActor.assumeIsolated {
                EnterEmailView(viewModel: self.resetPasswordViewModel())
            }
        }
    }
}

#Preview {
    NavigationStack {
        EnterEmailView(viewModel: Container.shared.resetPasswordViewModel())
            .environment(Container.shared.themeStore.resolve())
            .environment(Container.shared.authenCoordinator.resolve())
    }
}
