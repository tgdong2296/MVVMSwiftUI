//
//  RepoDetailViewModel.swift
//  MVVMSwiftUI
//

import Foundation
import FactoryKit

@Observable
@MainActor
final class RepoDetailViewModel {

    // MARK: - State

    let repository: GitHubRepo
    var viewState: ViewState = .indie

    // MARK: - Init

    init(repository: GitHubRepo) {
        self.repository = repository
    }
}

// MARK: - Factory Registration

extension Container {
    func repoDetailViewModel(repository: GitHubRepo) -> Factory<RepoDetailViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                RepoDetailViewModel(repository: repository)
            }
        }
    }
}
