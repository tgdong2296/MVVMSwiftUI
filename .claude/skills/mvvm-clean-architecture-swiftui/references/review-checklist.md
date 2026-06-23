# Review Checklist

Work through every section. A violation blocks approval.

---

## 1. Layer Isolation

- [ ] Views (`Scenes/`) contain **no** networking, persistence, or business logic.
- [ ] ViewModels (`Scenes/`) call Use Cases — never call services or API targets directly.
- [ ] Use Cases (`Domain/UseCase/`) contain no SwiftUI types and no view state — only logic.
- [ ] `Domain/Entities/` has **no** imports of frameworks or libraries.
- [ ] `Data/` does **not** import `Scenes/` or `Application/`.

## 2. Entities

- [ ] API response entities conform to `Decodable, Identifiable, Hashable, Sendable` (full `Codable` only when also encoded). snake_case JSON mapped via nested `CodingKeys`.
- [ ] Pure domain types (enums, state) conform only to what is semantically required; `Sendable` always.
- [ ] Any `static let samples` used by previews lives in a separate extension (not inline).
- [ ] No mutable properties accessible from outside (`private(set)` where needed).

## 3. Use Cases

- [ ] Scoped to a **domain/feature**, not a single action — groups all related methods (not limited to one `execute(...)`).
- [ ] Protocol is `@MainActor protocol {Name}UseCaseType: AnyObject`.
- [ ] Implementation is `@MainActor final class {Name}UseCase: {Name}UseCaseType`.
- [ ] Stateless — no `@Observable`, no `var` mutable stored properties.
- [ ] Services (and any global `Store`) are injected via `@Injected(\.keyPath)` — no `@ObservationIgnored` (Use Cases are not `@Observable`).
- [ ] Each method performs exactly one domain action and either returns a value or throws.
- [ ] Registered in `Container` as `.singleton`.

## 4. ViewModels

- [ ] Declared as `@Observable @MainActor final class {Name}ViewModel`.
- [ ] Each async section has its own stored `{section}State: ViewState = .indie`; the screen exposes a computed `var viewState: ViewState { combine([...]) }`.
- [ ] Every async function guards against duplicate calls on its **section** state before setting `.loading`.
- [ ] Every async function transitions its section state `.loading → .success` or `.loading → .error([message])` (`.error` carries a `[String]`).
- [ ] When typed messages matter, `APIError` is caught before the generic `Error` catch block.
- [ ] Each injected dependency uses `@Injected` on one line, `@ObservationIgnored private var` on the next — `@Injected` always first, both required because ViewModel is `@Observable`.
- [ ] No API service or storage injected directly — only Use Case protocol types.
- [ ] Registered in `Container` as **non-singleton**.

## 5. API Targets

- [ ] Conforms to `BaseTargetType, Sendable`.
- [ ] All computed properties (`path`, `method`, `task`, `headers`, `requiresAuth`, and `baseURL` if overridden) are `nonisolated`.
- [ ] `nonisolated var sampleData: Data` returns `MockHelper.loadJSON(from:)` for stubbed cases (or `Data()` for live cases); JSON stub files exist in `Data/Mock/`.
- [ ] Unauthenticated endpoints (login, register, public APIs) have `requiresAuth = false`; authenticated endpoints have `requiresAuth = true`.
- [ ] Registered in `Container` as `.singleton` — via `self.apiService()` for live/dev-gated endpoints, or a direct `MoyaProvider(stubClosure: MoyaProvider.delayedStub(...))` for always-stubbed endpoints.

## 6. Coordinators

- [ ] Route enum conforms to `Route`; every screen in the flow has a case.
- [ ] Route enum has `var id: {Name}Route { self }` for NavigationStack compatibility.
- [ ] `@Observable final class` with `var path: [{Name}Route] = []` as the **only** stored property.
- [ ] **No business logic and no feature/domain state** in the coordinator — methods do nothing but append/remove routes (no conditionals, data fetching, or domain decisions).
- [ ] `CoordinatorType` conformance is in an **extension** (not the class body).
- [ ] `rootView()` and `redirect(_:)` resolve views from `Container.shared`.
- [ ] Typed navigation methods exist on the class (`to{Screen}(params...)`, `goBack()`, `backToRoot()`) — Views never push routes directly.
- [ ] Flow wrapped with the project's coordinator navigation view (e.g. `CoordinatorNavigationView(coordinator:)`).
- [ ] Registered in `Container` as **non-singleton**.

## 7. Views

- [ ] ViewModel declared as `@State var viewModel: {Name}ViewModel` — `@State`, not `@StateObject`.
- [ ] Coordinator accessed via `@Environment({Flow}Coordinator.self)`.
- [ ] Global theme store accessed via `@Environment({ThemeStore}.self)` — use the project's store name.
- [ ] **No** hardcoded `Color.blue`, `.green`, `.red`, etc. — use the theme store's semantic color properties.
- [ ] The project's state container view (e.g. `CommonContainerView(viewState:)`) wraps all screens with async loading.
- [ ] Data loading triggered from `.task { await viewModel.load{X}() }`.
- [ ] Form fields use `@Validate(rules:)` and `.validation()` modifier — in the View only, never in ViewModel.
- [ ] View registered in `Container` as a factory **function** (not `var`) that resolves the ViewModel inline.

## 8. Global Stores

- [ ] Exist in `Application/Aggregates/`.
- [ ] Registered as `.singleton`.
- [ ] No feature-specific business logic lives in these stores.
- [ ] Views access them via `@Environment`, not `@Injected`.

## 9. Dependency Injection

- [ ] All `Container` registrations reference **protocol types** (not concrete implementations).

## 10. Concurrency

- [ ] All async calls use `async/await` — no `DispatchQueue` or completion handlers.
- [ ] Entities and API enums conform to `Sendable`.

## 11. Code Quality

- [ ] SwiftLint passes with zero violations (`swiftlint lint`).
- [ ] Project builds with zero compiler errors and warnings.
- [ ] No `force_cast`, `force_try`, or force unwrapping (`!`).
- [ ] All classes are `final`.
