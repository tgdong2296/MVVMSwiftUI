//
//  AppTheme.swift
//  VMPatternSwiftUI
//
//  Created by trinh.giang.dong on 4/10/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var displayName: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system:
            "gear"
        case .light:
            "sun.max.fill"
        case .dark:
            "moon.fill"
        }
    }
}
