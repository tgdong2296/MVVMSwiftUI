# MVVM + Clean Architecture

## Layer Map

```
Domain  ──────────────────────────────────────────────────────────────────────
  Entities          Pure Swift value types. Zero framework imports.
  UseCase           Protocol + implementation for domain business.

Application  ─────────────────────────────────────────────────────────────────
  Aggregates        Global app-level stores (manage global state).
  Supports          Swift/SwiftUI extensions — no business logic.
  Validations       @Validate wrapper + ValidationRule conformances.

Data  ────────────────────────────────────────────────────────────────────────
  API/Base          Moya primitives: BaseTargetType, APIService, APIError.
  API/Implementation  Feature-specific Moya targets.
  API/Token         TokenManager + TokenRefreshCoordinator.
  Local/SwiftData   ModelContext wrapper + CRUD helpers.
  Local/UserDefaults  UserDefaultsServiceType + implementation.
  Mock              JSON stubs + MockHelper.

Scenes  ──────────────────────────────────────────────────────────────────────
  Navigation        CoordinatorType, Route, CoordinatorNavigationView,
                    and one *Coordinator per flow.
  Common            Reusable UI components.
  {FeatureName}/    One folder per screen group — View + ViewModel pair (and sub-views if have).

Services  ────────────────────────────────────────────────────────────────────
  {Provider}/       Third-party SDK or external service wrappers behind protocol interfaces.
```

## Dependency Direction

```
Scenes  ──►  Domain/UseCase  ──►  Data/API
  │
  └──►  Application (global Stores, Validations)
```

Rule: **Dependencies only point inward.** A lower layer must never import a higher one.

| Allowed import | Forbidden import |
|----------------|------------------|
| Scenes → Domain/UseCase | UseCase → Scenes |
| Scenes → Application | Application → Scenes |
| UseCase → Data/API | Data → Scenes |
| Data → Domain/Entities | Domain/Entities → anything |

## Type Roles

| Type | Suffix | Layer | Mutable state? |
|------|--------|-------|----------------|
| Domain value | (none) | Domain/Entities | No (`struct`, `class`) |
| Use Case | `UseCase` | Domain/UseCase | No — stateless logic |
| Global Store | `Store` | Application/Aggregates | Yes (`@Observable`) |
| ViewModel | `ViewModel` | Scenes/{Feature} | Yes (`@Observable`) |
| Service | `Service` | Data or Services | No (`struct` or `final class`) |
| API target | `API` | Data | No (`enum`) |
| Coordinator | `Coordinator` | Scenes/Navigation | Path only (`@Observable`) |

### UseCase vs ViewModel vs Store

- **UseCase** — contains business logic for one domain action (e.g., `authentication`, `search`,...). Stateless; calls API services, handle business logic and returns results or throws. Registered as `.singleton`.
- **ViewModel** — orchestrates state for one screen. Holds `ViewState` and screen-specific data. Calls use cases — **never** call services directly. Registered as non-singleton.
- **Store (global)** — Holds state that must survive across flows (e.g: auth state, theme, purchase state,...). Injected via `@Environment` into the view hierarchy. Registered as `.singleton`.

## ViewState Lifecycle

```
.indie  ──►  .loading  ──►  .success
                        └──►  .error(String)
```

Every ViewModel async function that triggers a async call must:

1. Guard against duplicate calls: `guard viewState != .loading else { return }`.
2. Set `viewState = .loading` before the first `await`.
3. Set `viewState = .success` on the happy path.
4. Set `viewState = .error(message)` in all catch blocks.

Each screen will have a viewState property to represent the loading state of the entire screen. However, it can also be divided into multiple smaller states for each async task to reflect individual parts of the UI independently.

## ViewModel–UseCase Injection Pattern

```swift
@Observable
@MainActor
final class HomeViewModel {

    @Injected(\.searchRepositoriesUseCase)
    @ObservationIgnored private var searchRepositoriesUseCase
}
```

## View–ViewModel Binding Pattern

```swift
struct HomeView: View {

    @State var viewModel: HomeViewModel   // ← @State, not @StateObject

    var body: some View {
        CommonContainerView(viewState: viewModel.viewState) {
            // content
        }
        .task { await viewModel.loadRepositories() }
    }
}

// Container registration — ViewModel is resolved inside the View factory
extension Container {
    func homeView() -> Factory<HomeView> {
        Factory(self) {
            MainActor.assumeIsolated {
                HomeView(viewModel: Container.shared.homeViewModel())
            }
        }
    }
}
```
