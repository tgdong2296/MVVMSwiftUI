---
name: mvvm-clean-architecture-swiftui
description: "Develop new features, new screens, refactor, update and fix bugs following MVVM + Clean Architecture in SwiftUI projects. The architecture separates concerns into Domain (Entities + Use Cases), Data (API + local storage), Application (global stores + validations), and Scenes (Views + ViewModels + Coordinators), with FactoryKit for DI. Use when: adding a feature, creating a screen, fixing a bug, refactoring a ViewModel or coordinator, wiring DI, or reviewing code against MVVM conventions."
argument-hint: "Describe the task: new feature, screen, add screen, refactor, or bug fix"
---

# MVVM + Clean Architecture in SwiftUI

Follow this workflow to produce consistent output in any SwiftUI project using this architecture.

---

## Before You Start — Identify Project Conventions

This skill works across projects. Base utility names may differ slightly between codebases. Before writing any code, scan the project to confirm what these base utilities are called:

| Base Utility | Where to look | Typical name |
|---|---|---|
| View state enum | `Domain/Entities/` | `ViewState` |
| Global theme store | `Application/Aggregates/` | `ThemeStore` |
| DI container | Any `@Injected` usage | `Container` (FactoryKit) |
| Moya base target protocol | `Data/API/Base/` | `BaseTargetType` |
| Generic API service wrapper | `Data/API/Base/` | `APIService<T>` |
| API service factory helper | `Data/API/Base/` | `apiService(stubMapping:)` |
| Mock helper | `Data/Mock/` | `MockHelper` |
| Coordinator navigation wrapper | `Scenes/Navigation/` | `CoordinatorNavigationView` |
| Route protocol | `Scenes/Navigation/` | `Route` |

Use the names you find. The steps below use the typical names above — substitute the actual project names.

---

## First of all - Determine Task Type

Identify which workflow to execute based on the user's request:

| Task | Workflow |
|------|----------|
| "add a feature", "create a module", "create a flow" | → **New Feature Workflow** |
| "add a screen", "create a view", "add screen" | → **New Screen Workflow** |
| "refactor", "restructure", "move", "change" | → **Refactor Workflow** |
| "fix a bug", "something is broken", "something is incorrect" | → **Bug Fix Workflow** |
| "review", "check", "validate" | → **Review Workflow** |

If the request spans multiple types, start with the broadest scope (New Feature > New Screen > Refactor).

---

## New Feature Workflow

A **feature** is a domain-owning module: entity + API target + use case + coordinator + views with ViewModels.

1. Read [project-structure.md](./references/project-structure.md) to locate the target folders.

2. **Domain — Entities** — Create `Domain/Entities/{Name}.swift`:
   - API response entities (decoded from the server, never sent back) conform to `Decodable, Identifiable, Hashable, Sendable`. Use full `Codable` only when the type is also encoded (request body or local persistence). Map snake_case JSON via a nested `CodingKeys` enum.
   - Pure domain types (enums, state, config) only need the protocols that are semantically correct — `Sendable` is always required; `Codable` only if persisted or decoded; `Identifiable` only if used in a `List` (route enums and `AppFlow` use `var id: Self { self }`).
   - When a preview needs fixture data, add a `static let samples: [{Name}]` in a separate extension.

3. **Data — API Target** — Create `Data/API/Implementation/{Name}API.swift`:
   - `enum {Name}API: {BaseTargetType}, Sendable` with `nonisolated` computed properties (`path`, `method`, `task`, `headers`, `requiresAuth`). Override `baseURL` only when the endpoint hits a different host than the project default.
   - Set `requiresAuth = false` for unauthenticated endpoints (login, register, public APIs). Authenticated endpoints default to `true`.
   - Implement `nonisolated var sampleData: Data` — this is the mock source. Return `MockHelper.loadJSON(from: "{stub_file}")` for cases that should be stubbed, or `Data()` for cases that always hit the network. Add the matching JSON files in `Data/Mock/`.
   - Co-locate the response model (`struct {Name}Response: Decodable`) in the same file when it is specific to this target.
   - Register in `Container` as `.singleton`. Two registration styles are used:
     - **Live / optionally-stubbed** endpoint → `self.apiService()` (the `apiService(stubMapping:)` helper in `APIContainer`; pass a `stubMapping` closure only when you want `Environments.isDEV`-gated JSON stubbing).
     - **Always-stubbed** endpoint (e.g. an auth backend that isn't live yet) → build a `MoyaProvider<{Name}API>(stubClosure: MoyaProvider.delayedStub(0.5))` directly and pass it to `APIService(provider:tokenManager:refreshCoordinator:)`. This serves `sampleData` for every call.

4. **Domain — Use Case** — Create `Domain/UseCase/{Feature}/{Name}UseCase.swift`:
   - A use case is scoped to a **domain/feature**, not to a single action. It groups all the related functions for that domain — there is no rule to expose only one `execute(...)`. Name and structure it by the domain (e.g. `AuthUseCase`, `SearchRepositoriesUseCase`).
   - Define `@MainActor protocol {Name}UseCaseType: AnyObject` declaring one method per domain action; a single protocol commonly has several (e.g. `AuthUseCaseType` with `login`, `logout`, `register`, `requestOTP`, `verifyOTP`, `resetPassword`).
   - Implement `@MainActor final class {Name}UseCase: {Name}UseCaseType`.
   - Inject the API service via `@Injected(\.{name}ApiService)` — no `@ObservationIgnored` needed (Use Cases are not `@Observable`). A use case may also inject a global `Store` (e.g. `AuthUseCase` injects `appStateStore` to update `AppFlow` after login/logout).
   - Each method performs one specific domain action and either returns a value or `throws`.
   - Register in `Container` as `.singleton`.

5. **Navigation** — Create `Scenes/Navigation/{Name}Coordinator.swift`:
   - Only create if the feature need a new flow. Otherwise, add new screens to an existing coordinator.
      - Define `enum {Name}Route: Route` with a case per screen in the flow. Add `var id: {Name}Route { self }` for NavigationStack compatibility.
      - Create `@Observable final class {Name}Coordinator` with `var path: [{Name}Route] = []`.
   - A coordinator holds **no business logic and no feature/domain state** — the navigation `path` is the only stored property. Its methods do nothing but mutate `path` (append/remove routes).
   - Add navigation methods that only push/pop routes: `to{Screen}(params...)` (append), `goBack()` (remove last), `backToRoot()` (remove all). No conditionals, data fetching, or domain decisions belong here — that lives in ViewModels/Use Cases.
   - Conform to `CoordinatorType` in an **extension** — implement `rootView()` and `redirect(_:)`, resolving views from `Container.shared`.
   - Wrap the flow with the project's coordinator navigation view (e.g. `CoordinatorNavigationView(coordinator:)`), which sets the coordinator as an `@Environment` value automatically.
   - Register in `Container` as **non-singleton** (each flow gets its own instance).

6. **Scenes — ViewModel + View** — Create files in `Scenes/{Name}/`:
   - **`{Name}ViewModel.swift`**:
     - `@Observable @MainActor final class {Name}ViewModel`
     - For each injected dependency: `@Injected(\.keyPath)` on one line, `@ObservationIgnored private var name` on the next. Both attributes are required in `@Observable` types; order must be `@Injected` first. A global `Store` (e.g. `appStateStore`) may be injected here when the ViewModel reads or drives global state.
     - **Loading state** — give each independent async section its own stored `{section}State: ViewState = .indie`, then expose a single computed `var viewState: ViewState { combine([loadXState, loadYState]) }`. A screen with one async section still declares one section state plus the computed `viewState`. The `combine(_:)` helper folds multiple states into one (any `.error` wins and its `[String]` messages are merged, then `.loading`, then `.indie`, else `.success`).
     - Each async action: guard against duplicate calls on its own section state (`guard loadXState != .loading else { return }`), set that state to `.loading`, call the use case, then set `.success` or `.error([message])` — `.error` takes a `[String]`.
     - Register in `Container` as **non-singleton**.
   - **`{Name}View.swift`**:
     - `@State var viewModel: {Name}ViewModel` — declared as `@State`, not `@StateObject`.
     - Access the coordinator via `@Environment({Flow}Coordinator.self)`.
     - Access the global theme store via `@Environment({ThemeStore}.self)`.
     - Wrap the content in the project's state container view (e.g. `CommonContainerView(viewState:)`) for screens with async loading.
     - Trigger initial load from `.task { await viewModel.load{X}() }`.
     - Navigate exclusively via coordinator methods — never push routes directly from a View.
     - Register in `Container` as a factory **function** (not `var`) that resolves the ViewModel inline.

7. **DI** — All `Container` extensions must reference protocol types (not concrete classes) for use cases and services.

---

## New Screen Workflow

A **screen** is a single SwiftUI view + ViewModel added to an existing feature's coordinator.

1. Identify the owning coordinator in `Scenes/Navigation/`.
2. Add a new case to the coordinator's route enum.
3. Add a typed navigation method on the coordinator: `to{ScreenName}(params...)`.
4. Create `{Name}ViewModel.swift` in `Scenes/{Feature}/` — follow the same ViewModel rules as New Feature Workflow step 6.
5. Create `{Name}View.swift` in `Scenes/{Feature}/` — same rules: state container view, theme store, coordinator via `@Environment`.
6. Handle the new route case in `redirect(_:)` inside the coordinator's `CoordinatorType` extension.
7. Register the view in `Container`.

---

## Refactor Workflow

1. Read [mvvm-clean-architecture.md](./references/mvvm-clean-architecture.md) to confirm the correct layer boundaries.
2. Identify violations: business logic in Views, network calls in ViewModels (should be in Use Cases), mutable state in Coordinators, hardcoded colors, direct API access bypassing Use Cases.
3. Move code to the layer that owns it — never skip layers (`Scenes → Domain/UseCase → Data`).
4. Update `Container` registrations if ownership changes.
5. Re-run the **Review Workflow** after moving code.

---

## Bug Fix Workflow

1. Locate the affected component by layer:
   - UI glitch → `Scenes/{Feature}/{Name}View.swift`
   - Wrong state / loading bug → `Scenes/{Feature}/{Name}ViewModel.swift`
   - Wrong business logic → `Domain/UseCase/{Feature}/{Name}UseCase.swift`
   - Network error / decode failure → `Data/API/`
   - Navigation regression → `Scenes/Navigation/`
2. Read [data-flow.md](./references/data-flow.md) to trace the data path end-to-end.
3. Fix in the layer that owns the problem — do not patch symptoms in a higher layer.
4. Confirm view state transitions are correct after the fix.

---

## Review Workflow

Load [review-checklist.md](./references/review-checklist.md) and verify every item.

---

## Non-Negotiable Rules

- **Layer isolation**: Views hold zero business logic; Use Cases hold zero UI code; ViewModels only orchestrate state.
- **ViewModel as mediator**: ViewModels call Use Cases — never call API services or storage directly.
- **State ownership**: Only `@MainActor @Observable final class` ViewModels (and global Stores) manage mutable state.
- **Concurrency**: `async/await` only — no completion handlers or `DispatchQueue` calls in new code.
- **DI**: All dependencies resolved through `Container`; never construct dependencies inline.
- **Navigation**: Views must never push routes directly — always delegate to a coordinator method.
- **One coordinator per flow**: A coordinator owns all screens in its flow.
- **Coordinators are logic-free and state-free**: A coordinator holds no business logic and no feature/domain state — only the navigation `path`. Its methods do nothing but append/remove routes. Any condition or data decision belongs in a ViewModel or Use Case.
- **Use case = domain, not action**: A use case is scoped to a domain/feature and may expose many related methods — it is not limited to a single `execute(...)`.
- **Colors**: Always use the project's theme store semantic colors — never hardcode `Color.blue`, `.red`, etc.
- **Error propagation**: Use Cases `throw` — ViewModels catch and map to the section state's `.error([message])` case (`.error` carries a `[String]`). Catch typed `APIError` before the generic `Error` when you need typed messages.
- **Global app flow**: `AppStateStore` owns `AppFlow` (`.loading` / `.notAuthenticated` / `.authenticated`). Mutate it only via `appStateStore.update(_:)` from a Use Case or the app-level ViewModel — never set the flow from a feature View. Login transitions to `.authenticated`, logout to `.notAuthenticated`.
- **Forms**: Use `@Validate(rules:)` + `.validation()` modifier for all user-input fields. `@Validate` is View-only — it uses `@State` internally and silently breaks if moved into a ViewModel or used outside a SwiftUI body.
- **Sendable**: All entities and API enums conform to `Sendable`.

---

## Validate Before Finishing

Work through every item before marking the task done (except review tasks).  
Follow the rules and conventions in [review-checklist.md](./references/review-checklist.md) — do not skip or cut corners.

---

## Use References By Task

| Task | Reference |
|------|-----------|
| Choosing file locations and folder layout | [project-structure.md](./references/project-structure.md) |
| Understanding layer boundaries and data flow | [mvvm-clean-architecture.md](./references/mvvm-clean-architecture.md) |
| Tracing API → UseCase → ViewModel → View data path | [data-flow.md](./references/data-flow.md) |
| Reviewing or auditing existing code | [review-checklist.md](./references/review-checklist.md) |
