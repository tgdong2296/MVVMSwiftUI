//
//  ThemeStore.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/10/26.
//

import SwiftUI
import FactoryKit

// MARK: - Protocol

@MainActor
protocol ThemeStoreType {
    var currentTheme: AppTheme { get }
    
    func setTheme(_ theme: AppTheme)
    
    // MARK: - Semantic Colors
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    var errorColor: Color { get }
    var disabledColor: Color { get }
    var onPrimaryColor: Color { get }
    var overlayColor: Color { get }
}

// MARK: - Implementation

@Observable
@MainActor
final class ThemeStore: ThemeStoreType {
    
    // MARK: - Dependencies
    @Injected(\.userDefaultsService)
    @ObservationIgnored private var userDefaultsService
    
    // MARK: - State
    
    // MARK: - Properties
    private(set) var currentTheme: AppTheme = .system
    
    // MARK: - Constants
    private enum Keys {
        static let theme = "app_theme"
    }
    
    // MARK: - Init
    init() {}
    
    func restore() {
        if let raw = userDefaultsService.string(forKey: Keys.theme),
           let theme = AppTheme(rawValue: raw) {
            currentTheme = theme
        }
    }
    
    // MARK: - Actions
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        userDefaultsService.set(theme.rawValue, forKey: Keys.theme)
    }
    
    // MARK: - Semantic Colors
    var primaryColor: Color { .blue }
    var secondaryColor: Color { .green }
    var accentColor: Color { .blue }
    var backgroundColor: Color { Color(.systemBackground) }
    var surfaceColor: Color { Color(.secondarySystemBackground) }
    var errorColor: Color { .red }
    var disabledColor: Color { .gray }
    var onPrimaryColor: Color { .white }
    var overlayColor: Color { Color.black.opacity(0.1) }
}

// MARK: - Factory Registration
extension Container {
    var themeStore: Factory<ThemeStore> {
        Factory(self) {
            MainActor.assumeIsolated {
                let store = ThemeStore()
                store.restore()
                return store
            }
        }
        .singleton
    }
}
