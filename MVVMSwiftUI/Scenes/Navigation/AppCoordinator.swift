import SwiftUI
import FactoryKit

enum AppRoute: Route {
    case repoDetail(id: String, repository: GitHubRepo)
    case settings

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

    func toSettings() {
        path.append(.settings)
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
        case .settings:
            Container.shared.settingsView().resolve()
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
