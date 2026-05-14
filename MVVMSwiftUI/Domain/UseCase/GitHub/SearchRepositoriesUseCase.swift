//
//  SearchRepositoriesUseCase.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

// MARK: - Protocol

@MainActor
protocol SearchRepositoriesUseCaseType: AnyObject {
    func execute(query: String, page: Int, perPage: Int) async throws -> [GitHubRepo]
}

// MARK: - Implementation

@MainActor
final class SearchRepositoriesUseCase: SearchRepositoriesUseCaseType {

    @Injected(\.gitHubApiService)
    private var apiService

    func execute(query: String, page: Int, perPage: Int) async throws -> [GitHubRepo] {
        let response = try await apiService.request(
            .searchRepositories(query: query, page: page, perPage: perPage),
            type: GitHubSearchResponse.self
        )
        return response.items
    }
}

// MARK: - DI Registration

extension Container {
    var searchRepositoriesUseCase: Factory<SearchRepositoriesUseCaseType> {
        Factory(self) {
            MainActor.assumeIsolated {
                SearchRepositoriesUseCase()
            }
        }
    }
}
