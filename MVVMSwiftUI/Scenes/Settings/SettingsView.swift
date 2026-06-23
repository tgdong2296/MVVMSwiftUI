//
//  SettingsView.swift
//  MVVMSwiftUI
//

import SwiftUI
import FactoryKit

struct SettingsView: View {

    @State var viewModel: SettingsViewModel

    var body: some View {
        CommonContainerView(viewState: viewModel.viewState) {
            List {
                Section {
                    Button {
                        Task { await viewModel.logout() }
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Factory Registration

extension Container {
    func settingsView() -> Factory<SettingsView> {
        Factory(self) {
            MainActor.assumeIsolated {
                SettingsView(viewModel: Container.shared.settingsViewModel())
            }
        }
    }
}
