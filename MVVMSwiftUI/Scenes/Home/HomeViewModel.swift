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
    
    var searchQuery: String = "swift"
    
    var loadRepositoriesState: ViewState = .indie
    
    var viewState: ViewState {
        return combine([loadRepositoriesState])
    }
    
    // MARK: - Pagination

    private var currentPage: Int = 1
    private let perPage: Int = 20
    private(set) var hasMorePages: Bool = true
    private(set) var isLoadingMore: Bool = false

    // MARK: - Actions

    func loadRepositories() async {
        guard loadRepositoriesState != .loading else { return }
        loadRepositoriesState = .loading
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
            loadRepositoriesState = .success
        } catch {
            loadRepositoriesState = .error([error.localizedDescription])
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

