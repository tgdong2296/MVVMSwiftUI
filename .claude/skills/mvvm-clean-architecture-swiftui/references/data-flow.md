# Data Flow

## End-to-End API Request Lifecycle

```
View
  │
  ▼
ViewModel.loadX()          ← sets viewState = .loading
  │
  ▼
UseCase.execute(...)       ← business logic, no state
  │
  ▼
APIService.request/_requestWrapped/_requestVoid
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
  ├── success ──►  ViewModel: viewState = .success, data = response
  │
  └── failure ──►  ViewModel: viewState = .error(message)
                             (UseCase throws, ViewModel catches)
  │
  ▼
View re-renders via @Observable
```

## General Request Lifecycle

```
View
  │
  ▼
ViewModel.loadX()          ← sets viewState = .loading
  │
  ▼
UseCase.execute(...)       ← business logic, no state
  │
  ▼
Service
```

## Key Types

| Type | Responsibility |
|------|---------------|
| `{Name}ViewModel` | Holds screen state (`ViewState` + data); calls use cases |
| `{Name}UseCase` | Stateless business logic; calls API services and returns or throws |
| `BaseTargetType` | Declares path, method, task, headers, requiresAuth |
| `APIService` | Generic `request`, `requestWrapped`, `requestVoid` executor |
| `APIResponse<T>` | Wraps decoded server response |
| `APIError` | Typed error: `.unauthorized`, `.notFound`, `.serverError`, etc. |
| `APIErrorParser` | Maps HTTP codes and Moya errors to `APIError` |
| `TokenManager` | Thread-safe access/refresh token storage |
| `TokenRefreshCoordinator` | Retries after silent token refresh on 401 |

## ViewModel Error Handling Pattern

ViewModels catch errors thrown by use cases and map them to `ViewState.error`:

```swift
func loadRepositories() async {
    guard viewState != .loading else { return }
    viewState = .loading
    do {
        let items = try await searchRepositoriesUseCase.execute(
            query: searchQuery, page: currentPage, perPage: perPage
        )
        repositories = items
        viewState = .success
    } catch let error as APIError {
        viewState = .error(error.localizedDescription)
    } catch {
        viewState = .error(error.localizedDescription)
    }
}
```

Rule: **Always** catch `APIError` before the generic `Error` block so typed error messages surface correctly.

## Use Case Pattern

A Use Case is stateless and responsible for handling the application’s business logic. Each use case represents a specific domain, where the functions and business rules related to that domain are grouped together into a single use case.

```swift
// Example: Use case for searching Github Repositories
@MainActor
protocol GithubRepositoriesUseCaseType: AnyObject {
    func search(query: String, page: Int, perPage: Int) async throws -> [GitHubRepo]
}

@MainActor
final class GithubRepositoriesUseCase: GithubRepositoriesUseCaseType {

    @Injected(\.gitHubApiService)
    private var apiService

    func search(query: String, page: Int, perPage: Int) async throws -> [GitHubRepo] {
        let response = try await apiService.request(
            .searchRepositories(query: query, page: page, perPage: perPage),
            type: GitHubSearchResponse.self
        )
        return response.items
    }
}
```

## Mock Data

- `MockHelper` maps API cases to JSON file names via `stubMapping`.
- JSON stubs live in `Data/Mock/{name}.json`.
- Each `{Name}API` enum must implement `static func mockMapping() -> [{Name}API: String]`.

```swift
// Example: Container registration with stub support
extension Container {
    var gitHubApiService: Factory<APIService<GitHubAPI>> {
        Factory(self) {
            MainActor.assumeIsolated {
                Container.shared.apiService(stubMapping: GitHubAPI.mockMapping())
            }
        }
        .singleton
    }
}
```

## Local Storage

| Storage | Use case |
|---------|----------|
| `UserDefaultsService` | Lightweight key-value persistence (theme, tokens, flags) |
| SwiftData (`ContextStore`) | Structured offline data with relationships |

Access both through protocol-typed `Container` factories — never directly from a view or ViewModel.

## Token Lifecycle

```
Login  ──►  TokenManager.saveTokens(access:refresh:)
               │
         All authenticated requests attach the access token (AccessTokenPlugin)
               │
         401 received  ──►  TokenRefreshCoordinator.refreshTokenIfNeeded()
                                  │
                        success  ──►  retry original request
                        failure  ──►  AuthenStore.flow = .notAuthenticated (logout)
```

## Global State Flow

Global stores live in `Application/Aggregates/` and are injected at the app root:

```swift
    // Example: inject global state (Store) to app's root view
    var body: some Scene {
        WindowGroup {
            contentView
                .preferredColorScheme(themeStore.currentTheme.colorScheme)
                .environment(themeStore)
        }
    }
```
