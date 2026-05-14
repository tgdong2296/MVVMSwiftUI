# MVVMSwiftUI

iOS app built with SwiftUI, following MVVM + Clean Architecture. Uses FactoryKit for DI,
Moya for networking, SwiftData for local persistence, and a custom Coordinator pattern
for navigation.

---

## Commands

**Build:**
```bash
xcodebuild build -project MVVMSwiftUI.xcodeproj -scheme MVVMSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Run tests:**
```bash
xcodebuild test -project MVVMSwiftUI.xcodeproj -scheme MVVMSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Run a single test class:**
```bash
xcodebuild test -project MVVMSwiftUI.xcodeproj -scheme MVVMSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing MVVMSwiftUITests/MyTestClass
```

**Lint:**
```bash
swiftlint lint
```

**Lint with auto-fix:**
```bash
swiftlint --fix
```

---

## Architecture

Three-layer Clean Architecture. Dependencies always point inward:
`Scenes → Domain ← Data`

### Domain Layer (`Domain/`)
- **Entities** — plain Swift value types (e.g: `ViewState`, `AppFlow`, `AppTheme`, `GitHubRepository`,...). No framework imports.
- **Use Cases** — one `execute(...)` method per use case. Protocol + implementation pair.
  Each registers itself in `Container` at the bottom of its own file.

### Data Layer (`Data/`)
- **API** — `APIService<Target>` wraps Moya with async/await. Targets conform to
  `BaseTargetType`. Token injection via `AccessTokenPlugin`. Concurrent refresh
  serialized by `TokenRefreshCoordinator`.
- **Local** — `DataStore` protocol backed by `ContextStore` (SwiftData).
  Key-value storage via `UserDefaultsService`.
- **Stubs** — when `IS_DEV=YES`, `MockHelper.stubbedProvider` replaces real network
  calls with JSON files in `Stubs/`.

### Presentation Layer (`Scenes/`)
- **ViewModels** — `@Observable @MainActor final class`. All async work uses
  `async/await`. Dependencies injected via `@Injected(\.keyPath)`.
- **Views** — plain SwiftUI. Observe ViewModel directly — no `@StateObject` or
  `@ObservedObject`.
- **CommonContainerView** — wraps content with a `ViewState`-driven loading/error
  overlay. Use it for all screens that load remote data.

### Navigation
Coordinator pattern. Every flow has one coordinator.
`CoordinatorType` requires `rootView()` + `redirect(_:)`. Navigation is driven by
`path: [Route]` — push by appending, pop by removing.
`CoordinatorNavigationView` renders the `NavigationStack` driven by the coordinator's path.

### Dependency Injection
FactoryKit only. Rules:
- Register in a `Container` extension at the **bottom of the same file** as the type
- Singletons use `.singleton`
- ViewModels use `@Injected(\.keyPath)`
- Coordinators use `Container.shared.factory().resolve()`

### Validation
`@Validate` property wrapper — used in **Views**, not ViewModels.
Combine `ValidationRule` conformances (`EmailRule`, `PasswordRule`, `NotEmptyStringRule`)
and attach `ValidationModifier` to display inline errors.

### Environments
Build configs: `Environment/Development.xcconfig`, `Production.xcconfig`.
Access at runtime via `Environments.*` (reads `Info.plist`).
`Environments.isDEV` gates mock API usage.

### Combine Utilities
- `.asDriver()` — main-thread, error-silencing, replay(1) publisher
- `.asObservable()` — maps error type to `Error` for chains that expect `AnyPublisher<T, Error>`

---

## Code Conventions

- All classes **must** be `final` — SwiftLint enforces this with a custom `final_class` rule
- No `force_cast`, `force_try`, or `force_unwrapping` — these are lint **errors**
- Line length warning at 120 characters
- `.drive(...)` and `.subscribe(...)` calls must be broken to one call per line
- No access modifiers on extension members (`no_extension_access_modifier` rule)
- Use `async/await` everywhere — no Combine for async work in new code
- `@MainActor` on all ViewModels — never dispatch to main manually

---

## Testing

- Unit tests live in `MVVMSwiftUITests/`
- UI tests live in `MVVMSwiftUIUITests/`
- Inject mocks via protocol — never use `@testable import` to reach private state
- Use cases are tested by injecting a mock `DataStore` or mock API service
- ViewModels are tested by injecting mock use cases via FactoryKit overrides

**FactoryKit override pattern in tests:**
```swift
Container.shared.myUseCase.register { MockMyUseCase() }
```
Reset after each test with `Container.shared.reset()`.

---

## Key Files

| File | Purpose |
|------|---------|
| `MVVMSwiftUIApp.swift` | Entry point, root coordinator switch |
| `Application/Aggregates/ThemeStore.swift` | Global theme state, contain design token |
| `Data/API/APIService.swift` | Core network layer |
| `Data/Token/TokenRefreshCoordinator.swift` | Serializes concurrent token refreshes |
| `Domain/Entities/ViewState.swift` | Loading/error/success state used app-wide |
| `Scenes/Common/CommonContainerView.swift` | ViewState-driven screen wrapper |
| `Environment/Environments.swift` | Runtime config access |

---

## Gotchas

- **Mock API is tied to `IS_DEV=YES`**, not the scheme name. If mocks aren't firing,
  check the build setting, not the target.
- **`TokenManager` is a singleton** — never resolve a second instance or token state
  will desync. Always use `@Injected(\.tokenManager)`.
- **SwiftData context is not thread-safe** — all `ContextStore` calls must happen on
  the main actor. Don't call them from a background task without `await MainActor.run {}`.
- **`@Validate` is View-only** — it uses `@State` internally and will silently break
  if moved into a ViewModel or used outside a SwiftUI body.
- **Coordinator `path` is the source of truth** — never navigate by presenting views
  directly. All navigation goes through `redirect(_:)`.
- **JSON stubs must match the target file name** — `MockHelper` resolves stubs by
  target name. A missing stub silently returns empty data, not an error.

---

## Required

- Always run SwiftLint after completing all work.
- Always run unit tests after completing all work before creating pull request.
