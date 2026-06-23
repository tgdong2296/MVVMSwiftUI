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
  {FeatureName}/    One folder per screen group — View + ViewModel pair (and sub-views if any).

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
| Domain value | (none) | Domain/Entities | No (`struct` or `enum`) |
| Use Case | `UseCase` | Domain/UseCase | No — stateless logic |
| Global Store | `Store` | Application/Aggregates | Yes (`@Observable`) |
| ViewModel | `ViewModel` | Scenes/{Feature} | Yes (`@Observable`) |
| Service | `Service` | Data or Services | No (`struct` or `final class`) |
| API target | `API` | Data | No (`enum`) |
| Coordinator | `Coordinator` | Scenes/Navigation | Navigation `path` only — no logic, no feature state (`@Observable`) |

### UseCase vs ViewModel vs Store

- **UseCase** — owns the business logic for one **domain/feature** (e.g. `auth`, `search`), not for a single action. It groups all related functions (e.g. `AuthUseCase` exposes `login`, `logout`, `register`, `requestOTP`, `verifyOTP`, `resetPassword`) — there is no "single `execute(...)`" rule. Stateless; calls API services, applies business rules, returns results or throws. May inject a global `Store` to mutate app-wide state. Registered as `.singleton`.
- **ViewModel** — orchestrates state for one screen. Holds per-section `ViewState`s and screen-specific data. Calls Use Cases — **never** calls services or API targets directly. Registered as non-singleton.
- **Coordinator** — pure navigation router for one flow. Holds **no business logic and no feature/domain state** — only the navigation `path`. Its methods do nothing but append/remove routes; any condition or data decision belongs in a ViewModel or Use Case.
- **Store (global)** — holds state that must survive across flows (e.g. `AppStateStore`'s `AppFlow`, `ThemeStore`). Registered as `.singleton`. Consumed two ways: **Views** read a root-injected store via `@Environment` (here, `ThemeStore`); **ViewModels and Use Cases** that read or mutate global state inject the store via `@Injected(\.storeKeyPath)` (e.g. `AuthUseCase` and `AppViewModel` inject `appStateStore`). Mutate flow state only through the store's own method (`appStateStore.update(_:)`).

## ViewState Lifecycle

```
.indie  ──►  .loading  ──►  .success
                        └──►  .error([String])
```

`ViewState.error` carries a `[String]` (array of messages), so several failed sections can surface their errors at once.

Each independent async section owns its **own** stored `ViewState`. The screen exposes a single **computed** `viewState` that folds the section states via the `combine(_:)` helper — any `.error` wins (messages merged), then `.loading`, then `.indie`, else `.success`:

```swift
var loadRepositoriesState: ViewState = .indie
var viewState: ViewState { combine([loadRepositoriesState]) }
```

Every async function in a ViewModel that triggers a network or storage call must:

1. Guard against duplicate calls on its own section state: `guard loadXState != .loading else { return }`.
2. Set `loadXState = .loading` before the first `await`.
3. Set `loadXState = .success` on the happy path.
4. Set `loadXState = .error([message])` in all `catch` blocks.

A single-section screen still declares one section state plus the computed `viewState`.

## ViewModel–UseCase Injection Pattern

`@ObservationIgnored` is required on every `@Injected` property inside an `@Observable` type (ViewModels, Stores). It tells the Observation framework to ignore the property so FactoryKit's lazy resolution works correctly. Use Cases are **not** `@Observable`, so their injected services use `@Injected` alone — no `@ObservationIgnored`.

```swift
// ViewModel — @Observable, so @ObservationIgnored is required
@Observable
@MainActor
final class ProductListViewModel {

    @Injected(\.productUseCase)
    @ObservationIgnored private var productUseCase
}

// UseCase — not @Observable, so @ObservationIgnored is NOT needed
@MainActor
final class ProductUseCase: ProductUseCaseType {

    @Injected(\.productApiService)
    private var apiService
}
```

## View–ViewModel Binding Pattern

```swift
struct ProductListView: View {

    @State var viewModel: ProductListViewModel   // ← @State, not @StateObject

    var body: some View {
        CommonContainerView(viewState: viewModel.viewState) {
            // content
        }
        .task { await viewModel.loadProducts() }
    }
}

// Container registration — ViewModel resolved inside the View factory
// Note: use a func (not var) so each call returns a fresh non-singleton View+ViewModel pair
extension Container {
    func productListView() -> Factory<ProductListView> {
        Factory(self) {
            MainActor.assumeIsolated {
                ProductListView(viewModel: Container.shared.productListViewModel())
            }
        }
    }
}
```
