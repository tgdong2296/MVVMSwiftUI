//
//  HomeView.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 12/5/26.
//

import SwiftUI
import FactoryKit

struct HomeView: View {

    @Environment(AppCoordinator.self)
    private var coordinator

    @State var viewModel: HomeViewModel

    var body: some View {
        List(viewModel.repositories) { repo in
            RepositoryRowView(repository: repo)
                .onTapGesture {
                    coordinator.toRepoDetail(id: String(repo.id), repository: repo)
                }
        }
        .navigationTitle("Repositories")
        .overlay {
            if viewModel.repositories.isEmpty {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadRepositories()
        }
    }
}

// MARK: - Factory Registration

extension Container {
    func homeView() -> Factory<HomeView> {
        Factory(self) { @MainActor in
            HomeView(viewModel: Container.shared.homeViewModel())
        }
    }
}
