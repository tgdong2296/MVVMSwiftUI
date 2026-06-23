//
//  AppConfigUseCase.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 23/6/26.
//

import Foundation
import FactoryKit

// MARK: - Protocol

@MainActor
protocol AppConfigUseCaseType: AnyObject {
    func getAppFlow() async throws -> AppFlow
}

// MARK: - Implementation

@MainActor
final class AppConfigUseCase: AppConfigUseCaseType {

    func getAppFlow() async throws -> AppFlow {
        try await Task.sleep(for: .seconds(1))
        return .notAuthenticated
    }
}

// MARK: - DI Registration

extension Container {
    var appConfigUseCase: Factory<AppConfigUseCaseType> {
        Factory(self) {
            MainActor.assumeIsolated {
                AppConfigUseCase()
            }
        }
    }
}
