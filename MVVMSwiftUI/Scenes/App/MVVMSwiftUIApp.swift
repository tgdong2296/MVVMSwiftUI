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
    
    @Injected(\.authenStore)
    var authenStore
    
    @Injected(\.authenCoordinator)
    var authenCoordinator
    
    @Injected(\.appCoordinator)
    var appCoordinator
    
    @Injected(\.themeStore)
    var themeStore
    
    var body: some Scene {
        WindowGroup {
            contentView
                .preferredColorScheme(themeStore.currentTheme.colorScheme)
                .environment(themeStore)
        }
    }

    @ViewBuilder private var contentView: some View {
        switch authenStore.flow {
        case .notAuthenticated:
            CoordinatorNavigationView(coordinator: authenCoordinator)

        case .authenticated:
            CoordinatorNavigationView(coordinator: appCoordinator)
        }
    }
}
