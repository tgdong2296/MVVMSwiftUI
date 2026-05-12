//
//  VerifyOTPView.swift
//  VMPatternSwiftUI
//

import SwiftUI
import FactoryKit

struct VerifyOTPView: View {

    @Environment(AuthenCoordinator.self)
    var authenCoordinator

    @Environment(ThemeStore.self)
    private var themeStore

    @State var viewModel: ResetPasswordViewModel

    @Validate(name: "otp", autoValidate: true, .isNotEmpty(message: "Please enter the OTP code"))
    var otp: String = ""

    private var isFormValid: Bool {
        _otp.isValid
    }

    private var isSubmitDisabled: Bool {
        !isFormValid || viewModel.isLoading
    }

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            VStack(spacing: 16) {
                headerView
                otpField
            }

            verifyButton
        }
        .padding(.horizontal, 24)
        .navigationTitle("Verify OTP")
        .onChange(of: viewModel.resetStep) { _, newStep in
            if newStep == .otpVerified {
                authenCoordinator.toNewPassword()
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Enter verification code")
                .font(.title2)
                .fontWeight(.bold)

            Text("We've sent a code to **\(viewModel.resetEmail)**.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
    }

    private var otpField: some View {
        TextField("Enter OTP code", text: $otp)
            .textContentType(.oneTimeCode)
            .keyboardType(.numberPad)
            .autocorrectionDisabled()
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .validation(_otp.validationState)
    }

    private var verifyButton: some View {
        Button {
            Task {
                await viewModel.verifyOTP(otp: otp)
            }
        } label: {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Verify")
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

    func verifyOTPView() -> Factory<VerifyOTPView> {
        Factory(self) { @MainActor in
            VerifyOTPView(viewModel: self.resetPasswordViewModel())
        }
    }
}

#Preview {
    NavigationStack {
        VerifyOTPView(viewModel: Container.shared.resetPasswordViewModel())
            .environment(Container.shared.themeStore.resolve())
            .environment(Container.shared.authenCoordinator.resolve())
    }
}
