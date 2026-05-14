---
name: mvvm-clean-architecture-swiftui
description: "Develop new features, new screens, refactor, update and fix bugs following MVVM + Clean Architecture in SwiftUI projects. The architecture separates concerns into Domain (Entities + Use Cases), Data (API + local storage), Application (global stores + validations), and Scenes (Views + ViewModels + Coordinators), with FactoryKit for DI. Use when: adding a feature, creating a screen, fixing a bug, refactoring a ViewModel or coordinator, wiring DI, or reviewing code against MVVM conventions."
argument-hint: "Describe the task: new feature, screen, add screen, refactor, or bug fix"
---

# MVVM + Clean Architecture in SwiftUI

Follow this workflow to produce consistent output in this SwiftUI MVVM + Clean Architecture project.

## Step 1 — Determine Task Type

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
   - Conform to `Identifiable, Hashable, Codable, Sendable`.
   - Add `static let samples: [{Name}]` in an extension for previews.
3. **Data — API Target** — Create `Data/API/Implementation/{Name}API.swift`:
   - `enum {Name}API: BaseTargetType, Sendable` with `nonisolated` computed properties.
   - Add `static func mockMapping() -> [{Name}API: String]` in an extension.
   - Add JSON stubs in `Data/Mock/`.
   - Set `requiresAuth = false` only for auth endpoints.
   - Register in `Container` via `apiService(stubMapping:)` as `.singleton`.
4. **Domain — Use Case** — Create `Domain/UseCase/{Feature}/{Name}UseCase.swift`:
   - Define `@MainActor protocol {Name}UseCaseType: AnyObject` with one method per action.
   - Implement `@MainActor final class {Name}UseCase: {Name}UseCaseType`.
   - Inject API service via `@Injected(\.{name}ApiService)`.
   - Each method performs one specific domain action (e.g. `execute(query:page:perPage:)`).
   - Register in `Container` as `.singleton`.
5. **Navigation** — Create `Scenes/Navigation/{Name}Coordinator.swift`:
   - Define `enum {Name}Route: Route` with a case per screen in the flow.
   - Create `@Observable final class {Name}Coordinator` with `var path: [{Name}Route] = []`.
   - Conform to `CoordinatorType` in an extension — implement `rootView()` and `redirect(_:)`.
   - Never pass coordinators directly to views; inject via `CoordinatorNavigationView`.
   - Register in `Container` as non-singleton (each flow gets its own instance).
6. **Scenes — ViewModel + View** — Create files in `Scenes/{Name}/`:
   - Create `{Name}ViewModel.swift`:
     - `@Observable @MainActor final class {Name}ViewModel`
     - Inject use cases via `@Injected(\.useCase)` then `@ObservationIgnored` on separate lines.
     - Declare `var viewState: ViewState = .indie` for async loading screens.
     - Each action method: set `.loading`, call use case, set `.success` or `.error(msg)`.
     - Register in `Container` as non-singleton.
   - Create `{Name}View.swift`:
     - Declare `@State var viewModel: {Name}ViewModel` (passed in via init).
     - Access coordinator via `@Environment({Flow}Coordinator.self)`.
     - Access theme via `@Environment(ThemeStore.self) private var themeStore`.
     - Use `CommonContainerView` for screens with async loading.
     - Trigger loading from `.task { await viewModel.loadX() }`.
     - Navigate exclusively via coordinator methods.
     - Register in `Container` as a factory function that resolves the ViewModel.
7. **DI** — Wire all `Container` extensions referencing only protocols for use cases and services.

---

## New Screen Workflow

A **screen** is a single SwiftUI view + ViewModel added to an existing feature's coordinator.

1. Identify the owning coordinator in `Scenes/Navigation/`.
2. Add a new case to the coordinator's route enum.
3. Add a navigation method to the coordinator (`toX(id:)`).
4. Create `{Name}ViewModel.swift` in `Scenes/{Feature}/`:
   - Follow the same ViewModel rules as in the New Feature Workflow.
5. Create `{Name}View.swift` in `Scenes/{Feature}/`:
   - Same rules as feature views: `CommonContainerView`, `ThemeStore`, `@Environment({Flow}Coordinator.self)`.
6. Add the case to `redirect(_:)` in the coordinator extension.
7. Register the view in `Container`.

---

## Refactor Workflow

1. Read [mvvm-clean-architecture.md](./references/mvvm-clean-architecture.md) to confirm the correct layer boundaries.
2. Identify violations: business logic in views, network calls in ViewModels (should be in use cases), state in coordinators, hardcoded colors, direct networking bypassing use cases.
3. Move code to the correct layer — never skip layers (Scenes → Domain/UseCase → Data).
4. Update `Container` registrations if ownership changes.
5. Re-run the review checklist (Step 5 below).

---

## Bug Fix Workflow

1. Locate the affected component by layer:
   - UI glitch → `Scenes/{Feature}/{Name}View.swift`
   - Wrong state / loading bug → `Scenes/{Feature}/{Name}ViewModel.swift`
   - Wrong business logic → `Domain/UseCase/{Feature}/{Name}UseCase.swift`
   - Network error / decode failure → `Data/API/`
   - Navigation regression → `Scenes/Navigation/`
2. Read [data-flow.md](./references/data-flow.md) to trace the data path end-to-end.
3. Fix in the layer that owns the problem; do not patch symptoms in a higher layer.
4. Confirm `ViewState` transitions are correct after the fix.

---

## Review Workflow

Load [review-checklist.md](./references/review-checklist.md) and verify every item.

---

## Apply Non-Negotiable Rules

- **Layer isolation**: Views hold zero business logic; use cases hold zero UI code; ViewModels only orchestrate state.
- **ViewModel as mediator**: ViewModels call use cases — they must not call API services directly.
- **State ownership**: Only `@MainActor @Observable final class` ViewModels (and global Stores) manage mutable state.
- **Concurrency**: `async/await` only — no completion handlers or `DispatchQueue` calls in new code.
- **DI**: All dependencies resolved through `Container`; never construct dependencies inline.
- **Navigation**: Views must never push routes directly — always delegate to a coordinator method.
- **One coordinator per flow**: A coordinator owns all screens in its flow.
- **Colors**: Always use `themeStore.{semanticColor}` — never hardcode `Color.blue`, `.red`, etc.
- **Error propagation**: Use cases `throws` — ViewModels catch and map to `ViewState.error(message)`.
- **Forms**: Use `@Validate(rules:)` + `.validation()` modifier for all user-input fields.
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
