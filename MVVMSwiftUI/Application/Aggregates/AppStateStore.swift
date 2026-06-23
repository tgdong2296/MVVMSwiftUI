//
//  AppStateStore.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 23/6/26.
//

import SwiftUI
import FactoryKit

@Observable
@MainActor
final class AppStateStore {
    // MARK: - State
    private(set) var appFlow: AppFlow = .loading
    
    func update(_ appFlow: AppFlow) {
        self.appFlow = appFlow
    }
}

extension Container {
    var appStateStore: Factory<AppStateStore> {
        Factory(self) {
            MainActor.assumeIsolated {
                AppStateStore()
            }
        }
        .singleton
    }
}
