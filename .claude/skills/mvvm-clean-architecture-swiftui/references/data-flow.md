# Data Flow

## End-to-End API Request Lifecycle

```
View
  │
  ▼
ViewModel.load{X}()        ← sets load{X}State = .loading
  │
  ▼
UseCase.{action}(...)       ← business logic, no state (one of the use case's methods)
  │
  ▼
APIService.request / requestWrapped / requestVoid
  │
  ▼
Moya Provider
  │
  ▼
TokenRefreshCoordinator    ← intercepts 401, refreshes silently
  │
  ▼
HTTP Response
  │
  ▼
APIErrorParser             ← maps HTTP codes to APIError
  │
  ├── success ──►  ViewModel: load{X}State = .success, data = response
  │
  └── failure ──►  ViewModel: load{X}State = .error([message])
                             (UseCase throws, ViewModel catches)
  │
  ▼
View re-renders via @Observable
```

## General (Non-API) Request Lifecycle

```
View
  │
  ▼
ViewModel.load{X}()        ← sets load{X}State = .loading
  │
  ▼
UseCase.{action}(...)       ← business logic, no state (one of the use case's methods)
  │
  ▼
Service / LocalStorage
```

## Key Types

| Type | Responsibility |
| ------ | --------------- |
| `{Name}ViewModel` | Holds screen state (`ViewState` + data); calls Use Cases |
| `{Name}UseCase` | Stateless business logic; calls API services and returns or throws |
| `BaseTargetType` | Declares `path`, `method`, `task`, `headers`, `requiresAuth` |
| `APIService` | Generic `request`, `requestWrapped`, `requestVoid` executor |
| `APIResponse<T>` | Wraps decoded server response |
| `APIError` | Typed error: `.unauthorized`, `.notFound`, `.serverError`, etc. |
| `APIErrorParser` | Maps HTTP codes and Moya errors to `APIError` |
| `TokenManager` | Thread-safe access/refresh token storage |
| `TokenRefreshCoordinator` | Retries request after silent token refresh on 401 |

## ViewState & Loading-State Composition

`ViewState` is `.indie | .loading | .success | .error([String])` — the error case carries an **array** of messages so multiple failed sections can surface their errors together.

Each independent async section owns its own stored `ViewState`. The screen's `viewState` is a **computed** property that folds those section states with the `combine(_:)` helper (any `.error` wins and merges its `[String]`, then `.loading`, then `.indie`, else `.success`):

```swift
var loadRepositoriesState: ViewState = .indie
// var loadProfileState: ViewState = .indie   // add one per async section

var viewState: ViewState {
    combine([loadRepositoriesState])
}
```

## ViewModel Error Handling Pattern

ViewModels catch errors thrown by Use Cases and map them to `.error([message])` on the relevant section state. The guard and the state transitions operate on the **section** state, not the computed `viewState`. Catch the project's typed `APIError` before the generic `Error` block when you need typed messages to surface.

```swift
func load{Items}() async {
    guard load{Items}State != .loading else { return }
    load{Items}State = .loading
    do {
        let items = try await {feature}UseCase.execute(/* params */)
        self.items = items
        load{Items}State = .success
    } catch {
        load{Items}State = .error([error.localizedDescription])
    }
}
```

## Use Case Pattern

A Use Case is scoped to a **domain/feature**, not to a single action — it is stateless and groups *all* the related functions for that domain. There is no "one `execute(...)` per use case" rule: declare as many methods as the domain needs (e.g. `AuthUseCase` owns `login`, `logout`, `register`, `requestOTP`, `verifyOTP`, `resetPassword`).

```swift
// Protocol — one method per domain action; a single use case commonly has several
@MainActor
protocol {Feature}UseCaseType: AnyObject {
    func fetch{Items}(/* params */) async throws -> [{DomainEntity}]
    func {otherAction}(/* params */) async throws
}

// Implementation — calls API service, applies business rules, returns or throws
@MainActor
final class {Feature}UseCase: {Feature}UseCaseType {

    @Injected(\.{feature}ApiService)
    private var apiService

    // A use case may also inject a global Store to mutate app-wide state.
    @Injected(\.appStateStore)
    private var appStateStore

    func fetch{Items}(/* params */) async throws -> [{DomainEntity}] {
        let response = try await apiService.request(
            .{apiCase}(/* params */),
            type: {ResponseType}.self
        )
        return response.items  // apply any domain mapping here
    }

    func {otherAction}(/* params */) async throws {
        _ = try await apiService.requestWrapped(.{apiCase}(/* params */), type: EmptyResponse.self)
        appStateStore.update(.authenticated)  // e.g. flip app flow after the action
    }
}

// Container registration
extension Container {
    var {feature}UseCase: Factory<{Feature}UseCaseType> {
        Factory(self) { 
            MainActor.assumeIsolated {
                {Feature}UseCase()
            }
        }
        .singleton
    }
}
```

## Mock Data

- JSON stubs live in `Data/Mock/{filename}.json`. `MockHelper.loadJSON(from:)` reads them from the bundle.
- The mock source of truth is each target's `nonisolated var sampleData: Data` — return `MockHelper.loadJSON(from: "{stub_file}")` for stubbed cases, `Data()` for cases that always hit the network.
- Two registration styles, both `.singleton`:

```swift
// 1. Live (or dev-gated) endpoint — use the apiService() helper in APIContainer.
//    Pass a stubMapping closure only when you want Environments.isDEV-gated JSON stubbing;
//    omit it (as below) to always hit the network.
extension Container {
    var {feature}ApiService: Factory<APIService<{Feature}API>> {
        Factory(self) {
            MainActor.assumeIsolated {
                self.apiService()
            }
        }
        .singleton
    }
}

// 2. Always-stubbed endpoint — build a delayedStub provider directly; it serves sampleData
//    for every call regardless of the dev flag.
extension Container {
    var {feature}ApiService: Factory<APIService<{Feature}API>> {
        Factory(self) {
            MainActor.assumeIsolated {
                let provider = MoyaProvider<{Feature}API>(stubClosure: MoyaProvider.delayedStub(0.5))
                return APIService(
                    provider: provider,
                    tokenManager: self.tokenManager(),
                    refreshCoordinator: self.tokenRefreshCoordinator()
                )
            }
        }
        .singleton
    }
}
```

> The `apiService(stubMapping:)` helper still accepts an optional `(Target) -> String` mapping for `Environments.isDEV`-gated stubbing via `MockHelper.stubbedProvider(mapping:)`. No current target uses it — prefer `sampleData` for new targets.

## Local Storage

| Storage | When to use |
|---------|-------------|
| `UserDefaultsService` | Lightweight key-value persistence (theme, tokens, feature flags) |
| SwiftData (`ContextStore`) | Structured offline data with relationships |

Access both through protocol-typed `Container` factories — never directly from a View or ViewModel.

## Token Lifecycle

```
Login  ──►  AuthUseCase.login(...)  ──►  AppStateStore.update(.authenticated)
               │
         All authenticated requests attach the access token (AccessTokenPlugin)
               │
         401 received  ──►  TokenRefreshCoordinator refreshes silently
                                  │
                        success  ──►  retry original request
                        failure  ──►  AppStateStore.update(.notAuthenticated) (logout)
```

## Global State Flow

Global stores live in `Application/Aggregates/`. They are reached two ways depending on the consumer:

- **Views** read them via `@Environment` — but only the stores actually injected at the app root are available this way (in this project that is `ThemeStore`).
- **ViewModels and Use Cases** that need to read or mutate global state inject the store via `@Injected(\.storeKeyPath)` (with `@ObservationIgnored` inside an `@Observable` ViewModel). `AppStateStore` is consumed this way — `AuthUseCase` and the app-level `AppViewModel` both inject it.

`AppStateStore` owns the top-level `AppFlow` (`.loading` / `.notAuthenticated` / `.authenticated`) that the app entry point switches on. Mutate it only through `appStateStore.update(_:)`.

```swift
// App entry point — the root switches on appFlow and injects ThemeStore into the environment
var body: some Scene {
    WindowGroup {
        contentView                                  // switches on viewModel.appFlow
            .preferredColorScheme(themeStore.currentTheme.colorScheme)
            .environment(themeStore)
            .animation(.easeInOut, value: viewModel.appFlow)
    }
}
```
