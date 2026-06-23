# MVVMSwiftUI

iOS app built with SwiftUI, following MVVM + Clean Architecture. Uses FactoryKit for DI,
Moya for networking, SwiftData for local persistence, and a custom Coordinator pattern
for navigation.

---

## Requirements

- Xcode 26 or newer
- iOS 26.0 or newer

---

## Architecture

Three-layer Clean Architecture. Dependencies always point inward:
`Scenes → Domain ← Data`

### Domain Layer (`Domain/`)

- **Entities** — plain Swift value types (e.g: `ViewState`, `AppFlow`, `AppTheme`, `GitHubRepo`,...). No framework imports. API response entities conform to `Decodable, Identifiable, Hashable, Sendable` (full `Codable` only when also encoded).
- **Use Cases** — scoped to a **domain/feature**, not a single action. A use case groups all related methods (e.g. `AuthUseCase` exposes `login`, `logout`, `register`, `requestOTP`, `verifyOTP`, `resetPassword`) — there is **no** "one `execute(...)` per use case" rule. Protocol + implementation pair, stateless. May inject a global `Store` (e.g. `appStateStore`) to mutate app-wide state. Each registers itself in `Container` at the bottom of its own file.

### Data Layer (`Data/`)

- **API** — `APIService<Target>` wraps Moya with async/await. Targets conform to
  `BaseTargetType`. Token injection via `AccessTokenPlugin`. Concurrent refresh
  serialized by `TokenRefreshCoordinator`.
- **Local** — `DataStore` protocol backed by `ContextStore` (SwiftData).
  Key-value storage via `UserDefaultsService`.
- **Stubs** — JSON files live in `Data/Mock/`. Each API target's `nonisolated var sampleData: Data`
  is the mock source — return `MockHelper.loadJSON(from: "{file}")` for stubbed cases, `Data()` otherwise.
  Two registration styles: live/dev-gated endpoints use the `apiService()` helper (`Environments.isDEV` +
  optional `stubMapping` gate stubbing); always-stubbed endpoints build a
  `MoyaProvider(stubClosure: MoyaProvider.delayedStub(...))` directly.

### Presentation Layer (`Scenes/`)

- **ViewModels** — `@Observable @MainActor final class`. All async work uses
  `async/await`. Dependencies injected via `@Injected(\.keyPath)` + `@ObservationIgnored private var` on the next line (both required in `@Observable` types — `@Injected` always first).
- **Loading state** — `ViewState` is `.indie | .loading | .success | .error([String])` (the error case carries an **array** of messages). Each independent async section owns its own stored `ViewState`; the screen exposes a computed `var viewState: ViewState { combine([...]) }` that folds them (any `.error` wins and merges its messages, then `.loading`, then `.indie`, else `.success`). Guard and transition on the **section** state, not the computed `viewState`.
- **Views** — plain SwiftUI. Declare ViewModel as `@State var viewModel` — never `@StateObject` or `@ObservedObject`.
- **CommonContainerView** — wraps content with a `ViewState`-driven loading/error
  overlay. Use it for all screens that load remote data.

### Navigation

Coordinator pattern. Every flow has one coordinator.
`CoordinatorType` conformance goes in an **extension** (not the class body) and requires `rootView()` + `redirect(_:)`. Route enums must include `var id: {Route} { self }` for NavigationStack. Navigation is driven by `path: [Route]` — push by appending, pop by removing.
`CoordinatorNavigationView` renders the `NavigationStack` driven by the coordinator's path.
**Coordinators contain no business logic and no feature/domain state** — the navigation `path` is the only stored property, and methods do nothing but append/remove routes. Any condition or data decision belongs in a ViewModel or Use Case.

### App Flow & Global State

- Global stores live in `Application/Aggregates/` and are `.singleton`.
- Stores are consumed two ways: **Views** read a root-injected store via `@Environment` (here, only `ThemeStore` is injected at the root); **ViewModels and Use Cases** that read or mutate global state inject it via `@Injected(\.storeKeyPath)` (e.g. `AuthUseCase` and `AppViewModel` inject `appStateStore`).

### Theme & Colors

`ThemeStore` is the single source of truth for all colors. Access it via `@Environment(ThemeStore.self)` in Views.

**Semantic color tokens available on `ThemeStore`:**

| Token | Use |
| ------- | ----- |
| `primaryColor` | Primary actions, CTA buttons |
| `secondaryColor` | Secondary actions |
| `accentColor` | Highlights, interactive elements |
| `backgroundColor` | Screen/page backgrounds |
| `surfaceColor` | Cards, sheets, grouped content |
| `errorColor` | Error states, destructive actions |
| `disabledColor` | Disabled controls |
| `onPrimaryColor` | Text/icons on primary-colored backgrounds |
| `overlayColor` | Dimmed overlays, scrim backgrounds |

**Rules:**

- **Never hardcode** `Color.blue`, `Color.red`, `.green`, `.white`, `.black`, etc. — always use `themeStore.semanticToken`.
- `ThemeStore` is injected at the app root via `.environment(themeStore)` — access it in Views with `@Environment(ThemeStore.self) private var themeStore`.
- ViewModels and Use Cases must **never** reference `ThemeStore` — color decisions belong in Views only.
- `currentTheme` drives `preferredColorScheme` at the root. Never set `colorScheme` on individual views.
- Theme changes are persisted automatically via `setTheme(_:)`. Never write the theme key to UserDefaults manually.

### Dependency Injection

FactoryKit only. Rules:

- Register in a `Container` extension at the **bottom of the same file** as the type
- Singletons use `.singleton`; ViewModels and Coordinators are **non-singleton**
- All `Container` registrations reference **protocol types**, not concrete classes
- View factories use `func` (not `var`) so each call returns a fresh View+ViewModel pair
- All factory closures use `MainActor.assumeIsolated { }` to satisfy Swift concurrency
- Coordinators use `Container.shared.coordinatorName().resolve()`

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
- `@MainActor` on all ViewModels and UseCase protocols — never dispatch to main manually
- UseCase protocols must conform to `AnyObject`: `@MainActor protocol {Name}UseCaseType: AnyObject`
- All entities and API enums must conform to `Sendable`
- ViewModels map thrown errors to `.error([message])` on the section state; catch typed `APIError` before the generic `Error` when typed messages matter

---

## Key Files

| File | Purpose |
| ------ | --------- |
| `Scenes/App/MVVMSwiftUIApp.swift` | Entry point, root `AppFlow` switch |
| `Application/Aggregates/AppStateStore.swift` | Global `AppFlow` (loading/auth) state |
| `Application/Aggregates/ThemeStore.swift` | Global theme state, contain design token |
| `Data/API/Base/APIService.swift` | Core network layer |
| `Data/API/Token/TokenRefreshCoordinator.swift` | Serializes concurrent token refreshes |
| `Environment/Environments.swift` | Runtime config access |

---

## Gotchas

- **Dev-gated mocks are tied to `IS_DEV=YES`**, not the scheme name. This only affects endpoints
  registered through the `apiService(stubMapping:)` helper. Always-stubbed endpoints (a direct
  `MoyaProvider(stubClosure: .delayedStub(...))`) serve `sampleData` regardless of the flag. If mocks
  aren't behaving as expected, check which registration style the target uses.
- **`TokenManager` is a singleton** — never resolve a second instance or token state
  will desync. Always use `@Injected(\.tokenManager)`.
- **SwiftData context is not thread-safe** — all `ContextStore` calls must happen on
  the main actor. Don't call them from a background task without `await MainActor.run {}`.
- **`@Validate` is View-only** — it uses `@State` internally and will silently break
  if moved into a ViewModel or used outside a SwiftUI body.
- **Coordinator `path` is the source of truth** — never navigate by presenting views
  directly. All navigation goes through `redirect(_:)`.
- **`MockHelper.loadJSON(from:)` `fatalError`s on a missing file** — the `sampleData` filename must
  match a real JSON in `Data/Mock/` (added to the bundle), or the app crashes at request time.
- **`@ObservationIgnored` is required on every `@Injected` inside `@Observable` types** —
  missing it causes FactoryKit's lazy resolution to break silently.
- **View Container registrations must be `func`, not `var`** — using `var` creates a
  singleton View, so navigation pushes the same instance instead of a fresh one.
- **`CoordinatorType` conformance must be in an extension** — putting it in the class
  body causes compiler errors with associated type inference in some Xcode versions.

---

## Commands

**Lint:**

```bash
swiftlint lint
```

**Lint with auto-fix:**

```bash
swiftlint --fix
```

---

## Required for coding tasks

- Always update Localizable.xcstrings after add/edit/remove String.
- Always run SwiftLint after completing all work.
- Always build project successfully.
- If using XcodeBuildMCP, use the installed XcodeBuildMCP skill before calling XcodeBuildMCP tools.
