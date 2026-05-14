# Review Checklist

Work through every section. A violation blocks approval.

---

## 1. Layer Isolation

- [ ] Views (`Scenes/`) contain **no** networking, persistence, or business logic.
- [ ] ViewModels (`Scenes/`) call use cases — never call services directly.
- [ ] Use Cases (`Domain/UseCase/`) contain no SwiftUI types and no `ViewState`, only contain logic.
- [ ] `Domain/Entities/` has **no** imports of framework and libraries.
- [ ] `Data/` does **not** import `Scenes/` or `Application/`.

## 2. Entities

- [ ] Conforms to `Identifiable, Hashable, Codable, Sendable`.
- [ ] `static let samples` exists in an extension (not inline) for preview support.
- [ ] No mutable properties accessible from outside (`private(set)` where needed).

## 3. Use Cases

- [ ] Protocol is `@MainActor protocol {Name}UseCaseType: AnyObject`.
- [ ] Implementation is `@MainActor final class {Name}UseCase: {Name}UseCaseType`.
- [ ] Stateless — no `@Observable`, no `var` mutable stored properties.
- [ ] Services are injected via `@Injected(\.{name}Service)`.
- [ ] Each method performs exactly one domain action and either returns a value or throws.
- [ ] Registered in `Container` as `.singleton` if need.

## 4. ViewModels

- [ ] Declared as `@Observable @MainActor final class {Name}ViewModel`.
- [ ] `var viewState: ViewState = .indie` for screens with async loading.
- [ ] Every async function guards against duplicate calls before setting `.loading`.
- [ ] Every async function sets `.loading → .success / .error`.
- [ ] `APIError` is caught before the generic `Error` catch block.
- [ ] `@Injected` appears **before** `@ObservationIgnored` — on separate lines.
- [ ] No API service injected directly — only use case protocol types.
- [ ] Registered in `Container` as **non-singleton**.

## 5. API Targets

- [ ] Conforms to `BaseTargetType, Sendable`.
- [ ] All computed properties (`path`, `method`, `task`, `headers`, `requiresAuth`) are `nonisolated`.
- [ ] `mockMapping()` returns a complete mapping covering all cases.
- [ ] Auth-only endpoints set `requiresAuth = false`.
- [ ] Registered in `Container` via `apiService(stubMapping:)` as `.singleton`.

## 6. Coordinators

- [ ] Route enum conforms to `Route`; every screen in the flow has a case.
- [ ] `@Observable final class` with `var path: [{Feature}Route] = []`.
- [ ] `CoordinatorType` conformance is in an **extension** (not the class body).
- [ ] `rootView()` and `redirect(_:)` resolve views from `Container.shared`.
- [ ] Navigation methods (`toDetail(id:)`, `goBack()`, `backToRoot()`) exist — views never push routes directly.
- [ ] Flow wrapped with `CoordinatorNavigationView(coordinator:)`.
- [ ] Registered in `Container` as **non-singleton**.

## 7. Views

- [ ] ViewModel declared as `@State var viewModel: {Name}ViewModel` (passed in via init).
- [ ] Coordinator accessed via `@Environment({Flow}Coordinator.self)`.
- [ ] Theme accessed via `@Environment(ThemeStore.self) private var themeStore`.
- [ ] **No** hardcoded `Color.blue`, `.green`, `.red`, etc. — use `themeStore.{semanticColor}`.
- [ ] `CommonContainerView(viewState:)` wraps all screens with async loading.
- [ ] Data loading triggered from `.task { await viewModel.loadX() }`.
- [ ] Form fields use `@Validate(rules:)` and `.validation()` modifier.
- [ ] View registered in `Container` as a factory function that resolves the ViewModel inline.

## 8. Global Stores (AuthenStore, ThemeStore)

- [ ] Exist in `Application/Aggregates/`.
- [ ] Stores are registered as `.singleton`.
- [ ] No feature-specific business logic lives in these stores.
- [ ] Views access them via `@Environment`, not `@Injected`.

## 9. Dependency Injection

- [ ] All `Container` registrations reference protocol types (not concrete implementations).

## 10. Concurrency

- [ ] All async calls use `async/await` — no `DispatchQueue` or completion handlers.
- [ ] Entities and API enums conform to `Sendable`.

## 11. Code Quality

- [ ] SwiftLint's commands `swiftlint` passes with zero violations.
- [ ] Project builds with zero compiler errors and warnings.
- [ ] No `force_cast`, `force_try`, or `force_unwrapping`.
- [ ] All classes are `final`.
