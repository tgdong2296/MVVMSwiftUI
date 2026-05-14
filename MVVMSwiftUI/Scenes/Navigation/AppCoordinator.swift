import SwiftUI
import FactoryKit

enum AppRoute: Route {
    case repoDetail(id: String, repository: GitHubRepo)
    
    var id: AppRoute { self }
}

@Observable
final class AppCoordinator {
    var path: [AppRoute] = []
    
    func goBack() {
        path.removeLast()
    }
    
    func toRepoDetail(id: String, repository: GitHubRepo) {
        path.append(.repoDetail(id: id, repository: repository))
    }
    
    func backToRoot() {
        path.removeAll()
    }
}

// MARK: - Coordinator
extension AppCoordinator: CoordinatorType {
    
    @ViewBuilder
    func rootView() -> some View {
        Container.shared.homeView().resolve()
    }
    
    @ViewBuilder
    func redirect(_ path: AppRoute) -> some View {
        switch path {
        case .repoDetail(_, let repository):
            Container.shared.repoDetailView(repository: repository).resolve()
        }
    }
}

extension Container {
    
    var appCoordinator: Factory<AppCoordinator> {
        Factory(self) {
            MainActor.assumeIsolated {
                AppCoordinator()
            }
        }
    }
}
