//
//  HomeViewModel.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 12/5/26.
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class HomeViewModel {

    // MARK: - Dependencies

    @Injected(\.searchRepositoriesUseCase)
    @ObservationIgnored private var searchRepositoriesUseCase

    // MARK: - State

    var repositories: [GitHubRepo] = []
    var viewState: ViewState = .indie
    var searchQuery: String = "swift"

    // MARK: - Pagination

    private var currentPage: Int = 1
    private let perPage: Int = 20
    private(set) var hasMorePages: Bool = true
    private(set) var isLoadingMore: Bool = false

    // MARK: - Actions

    func loadRepositories() async {
        guard viewState != .loading else { return }
        viewState = .loading
        currentPage = 1
        hasMorePages = true

        do {
            let items = try await searchRepositoriesUseCase.execute(
                query: searchQuery,
                page: currentPage,
                perPage: perPage
            )
            repositories = items
            hasMorePages = items.count == perPage
            viewState = .success
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    func loadMoreIfNeeded(currentItem: GitHubRepo) async {
        guard hasMorePages, !isLoadingMore,
              repositories.last?.id == currentItem.id else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let items = try await searchRepositoriesUseCase.execute(
                query: searchQuery,
                page: currentPage,
                perPage: perPage
            )
            repositories.append(contentsOf: items)
            hasMorePages = items.count == perPage
        } catch {
            currentPage -= 1
        }

        isLoadingMore = false
    }

    func search() async {
        await loadRepositories()
    }
}

// MARK: - Factory Registration

extension Container {
    var homeViewModel: Factory<HomeViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                HomeViewModel()
            }
        }
    }
}

