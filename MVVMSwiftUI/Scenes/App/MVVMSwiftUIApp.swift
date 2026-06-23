//
//  MVVMSwiftUIApp.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 12/5/26.
//

import SwiftUI
import FactoryKit

@main
struct VMPatternSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @Injected(\.authenCoordinator)
    var authenCoordinator
    
    @Injected(\.appCoordinator)
    var appCoordinator
    
    @Injected(\.themeStore)
    var themeStore
    
    @State var viewModel: AppViewModel = Container.shared.appViewModel.resolve()
    
    var body: some Scene {
        WindowGroup {
            contentView
                .preferredColorScheme(themeStore.currentTheme.colorScheme)
                .environment(themeStore)
                .animation(.easeInOut, value: viewModel.appFlow)
        }
    }

    @ViewBuilder private var contentView: some View {
        switch viewModel.appFlow {
        case .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: themeStore.accentColor))
                .task {
                    await viewModel.loadAppFlow()
                }
            
        case .notAuthenticated:
            CoordinatorNavigationView(coordinator: authenCoordinator)

        case .authenticated:
            CoordinatorNavigationView(coordinator: appCoordinator)
                .task {
                    await viewModel.loadData()
                }
        }
    }
}
