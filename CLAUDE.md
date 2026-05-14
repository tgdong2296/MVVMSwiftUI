# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build & Run:** Open `MVVMSwiftUI.xcodeproj` in Xcode and use Cmd+R. There is no CLI build command — use `xcodebuild` for scripted builds.

**Lint:**
```bash
swiftlint lint
```

**Run tests:**
```bash
xcodebuild test -project MVVMSwiftUI.xcodeproj -scheme MVVMSwiftUI -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Run a single test class:**
```bash
xcodebuild test -project MVVMSwiftUI.xcodeproj -scheme MVVMSwiftUI -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing MVVMSwiftUITests/MyTestClass
```

## Architecture

The app follows **MVVM + Clean Architecture** with three distinct layers:

### 1. Domain Layer (`Domain/`)
- **Entities** — plain Swift types (`ViewState`, `AppFlow`, `AppTheme`, `GitHubRepository`)
- **Use Cases** — `*UseCaseType` protocols + `*UseCase` implementations; each has a single `execute(...)` method and registers itself with FactoryKit's `Container`

### 2. Data Layer (`Data/`)
- **API** — built on [Moya](https://github.com/Moya/Moya); `APIService<Target>` wraps Moya with async/await, auto token injection via `AccessTokenPlugin`, and transparent token refresh via `TokenRefreshCoordinator`. Targets conform to `BaseTargetType`. In DEV mode with `IS_DEV=YES`, `MockHelper.stubbedProvider` replaces real network calls with local JSON stubs.
- **Local** — `DataStore` protocol over SwiftData (`ContextStore`); `UserDefaultsService` for key-value persistence
- **Token** — `TokenManager` (singleton) holds access/refresh tokens; `TokenRefreshCoordinator` serializes concurrent refresh attempts

### 3. Scenes / Presentation Layer (`Scenes/`)
- **ViewModels** — marked `@Observable @MainActor final class`. Use `async/await` for all async work. Dependencies are injected via `@Injected(\.keyPath)` from FactoryKit.
- **Views** — SwiftUI views that observe their `@Observable` ViewModel directly (no `@StateObject`/`@ObservedObject`)
- **Common views** — `CommonContainerView` wraps content with a `ViewState`-driven loading/error overlay

### Navigation (Coordinator Pattern)
Navigation uses a custom **Coordinator** pattern:
- `CoordinatorType` protocol holds a `path: [Route]` array and requires `rootView()` + `redirect(_:)` implementations
- `CoordinatorNavigationView` renders `NavigationStack` driven by the coordinator's path
- `AuthenCoordinator` manages the unauthenticated flow; `AppCoordinator` manages the authenticated flow
- The root `MVVMSwiftUIApp` switches between coordinators based on `AuthenStore.flow`

### Dependency Injection
[FactoryKit](https://github.com/hmlongco/Factory) is used exclusively. Each type registers itself in a `Container` extension at the bottom of its own file. Singletons (stores, token manager) use `.singleton`. Use `@Injected(\.keyPath)` in ViewModels; use `Container.shared.factory().resolve()` in coordinators for view creation.

### Validation
`@Validate` is a custom `@propertyWrapper` used directly in SwiftUI Views (not ViewModels). Combine `ValidationRule` conformances (`EmailRule`, `PasswordRule`, `NotEmptyStringRule`) and use `ValidationModifier` to display error messages.

### Environments
Build configs live in `Environment/Development.xcconfig` and `Production.xcconfig`. Access values at runtime via `Environments.*` static properties (reads from `Info.plist` via `Bundle.main.infoDictionary`). `Environments.isDEV` controls mock API usage.

### Combine Utilities
- `.asDriver()` — main-thread, error-silencing, replay(1) publisher
- `.asObservable()` — maps error type to `Error` for use in chains that expect `AnyPublisher<T, Error>`

## SwiftLint Rules to Note
- All classes **must** be `final` (custom `final_class` rule)
- Line length warning at 120 characters
- `force_cast`, `force_try`, `force_unwrapping` are errors — avoid them
- `.drive(...)` and `.subscribe(...)` calls must be broken across lines (one call per line)
- `no_extension_access_modifier` is enabled — don't add `public`/`internal` to extension members
