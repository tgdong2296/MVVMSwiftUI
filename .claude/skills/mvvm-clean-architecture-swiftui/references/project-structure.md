# Project Structure

## Directory Tree

```
{AppName}/
├── Info.plist
│
├── Domain/                           # Pure Swift — zero framework dependencies
│   ├── Entities/                     # Value types: Decodable/Codable, Identifiable, Hashable, Sendable
│   │   ├── {AppTheme}.swift          # Theme definition — exact name varies per project
│   │   ├── {AppFlow}.swift           # .loading | .notAuthenticated | .authenticated — top-level app flow
│   │   ├── {ViewState}.swift         # .indie | .loading | .success | .error([String]) — exact name varies
│   │   ├── {Name}.swift              # Feature domain entity
│   │   └── {Name}.swift
│   └── UseCase/                      # One subfolder per feature domain
│       ├── {Feature}/
│       │   ├── {Name}UseCase.swift
│       │   └── {Name}UseCase.swift
│       └── {Feature}/
│           ├── {Name}UseCase.swift
│           └── {Name}UseCase.swift
│
├── Application/                      # Cross-cutting app-layer concerns
│   ├── Aggregates/                   # Global app-level stores only (observable singletons)
│   │   ├── {AppStateStore}.swift     # Owns AppFlow (loading/auth state) — exact name varies per project
│   │   └── {ThemeStore}.swift        # Color scheme management — exact name varies per project
│   ├── Supports/                     # Swift/SwiftUI extensions and utilities
│   └── Validations/                  # Validation Rules and Validators
│
├── Data/                             # Infrastructure: network, storage, mocks
│   ├── API/
│   │   ├── Base/                     # Shared networking primitives — project-provided, do not recreate
│   │   │   ├── BaseTargetType.swift  # Moya TargetType extension
│   │   │   ├── APIService.swift      # Generic async/await request executor
│   │   │   ├── APIContainer.swift    # Factory registration helpers (apiService(stubMapping:))
│   │   │   ├── APIError.swift        # Typed error enum
│   │   │   ├── APIErrorParser.swift
│   │   │   └── APIResponse.swift     # Generic wrapped response type
│   │   ├── Implementation/           # Feature-specific Moya targets — one file per feature
│   │   │   ├── {Feature}API.swift
│   │   │   └── {Feature}API.swift
│   │   └── Token/                    # JWT lifecycle management — project-provided
│   │       ├── TokenManager.swift    # Token storage and access
│   │       └── TokenRefreshCoordinator.swift  # Serializes concurrent token refreshes
│   ├── Local/
│   │   ├── SwiftData/                # SwiftData-backed local persistence
│   │   │   ├── DataStore.swift       # DataStore protocol
│   │   │   └── ContextStore.swift    # SwiftData implementation (main-actor only)
│   │   └── UserDefaults/             # Key-value local storage
│   │       ├── UserDefaultsServiceType.swift
│   │       └── UserDefaultsService.swift
│   └── Mock/                         # JSON stubs for dev/stub mode
│       ├── MockHelper.swift          # Project-provided stub loader
│       └── {name}.json               # One file per API response
│
├── Scenes/                           # SwiftUI views, ViewModels, and coordinators
│   ├── App/
│   │   ├── {AppName}App.swift        # Root scene switcher (auth vs. main flow)
│   │   └── AppDelegate.swift         # UIApplicationDelegate
│   ├── Navigation/                   # Coordinator infrastructure — project-provided
│   │   ├── CoordinatorType.swift     # CoordinatorType protocol definition
│   │   ├── CoordinatorNavigationView.swift  # NavigationStack driven by coordinator path
│   │   ├── Route.swift               # Route base protocol
│   │   └── {Name}Coordinator.swift   # One coordinator per flow
│   ├── Common/                       # Reusable UI components — project-provided
│   │   ├── Common{Name}View.swift
│   │   ├── Common{Name}View.swift
│   │   ├── CommonContainerView.swift # ViewState-driven loading/error screen wrapper
│   │   ├── CommonErrorView.swift
│   │   ├── CommonLoadingView.swift
│   │   └── ValidationModifier.swift  # Inline validation error display
│   ├── {ScreenName}/                 # One folder per screen or screen group
│   │   ├── {ScreenName}View.swift    # SwiftUI view (may include sub-views / row views)
│   │   └── {ScreenName}ViewModel.swift  # @Observable ViewModel
│   └── {ScreenName}/
│       ├── {ScreenName}View.swift
│       └── {ScreenName}ViewModel.swift
│
├── Services/
│   └── {ServiceName}/
│       ├── {ServiceName}ServiceType.swift
│       └── {ServiceName}Service.swift
│
├── Environment/                      # Build-time configuration
│   ├── Development.xcconfig
│   ├── Production.xcconfig
│   └── Environments.swift            # Reads environment configurations
│
└── Assets/                           # Images, Colors, Fonts, Localization
```

---

## Layer Responsibilities

| Layer | Folder | Key Rule |
| ------- | -------- | ---------- |
| **Domain** | `Domain/` | Pure Swift — no library or SDK imports |
| **Application** | `Application/` | Global stores, extensions, validations — no network calls |
| **Data** | `Data/` | All I/O: API, SwiftData, UserDefaults, mocks — base classes are project-provided |
| **Scenes** | `Scenes/` | SwiftUI views + ViewModels + coordinators — no direct API access |
| **Services** | `Services/` | Third-party SDK wrappers behind protocol interfaces |

> **Project-provided vs feature-specific**: Files in `Data/API/Base/`, `Scenes/Navigation/`, and `Scenes/Common/` are part of the project's base infrastructure — do not recreate them. New feature work always goes into `Data/API/Implementation/`, `Domain/UseCase/{Feature}/`, and `Scenes/{FeatureName}/`.

### Domain/Entities

Declared in `Domain/Entities/`. Pure Swift value types — no frameworks and libraries. API response entities conform to `Decodable, Identifiable, Hashable, Sendable` (full `Codable` only when also encoded); pure domain types conform to just what is semantically required (`Sendable` always). Provide `static let samples` in an extension when previews need fixtures.

### Domain/UseCase

Declared in `Domain/UseCase/{Feature}/`. One file per use-case group. Contains the business logic that orchestrates API calls and domain transformations, domain business logic. Stateless — no `@Observable`, no stored mutable state.

### Application/Aggregates

Global state for app, any component can observe, singleton stores injected as `@environment` into the view hierarchy from the app entry point. Do **not** add feature-specific ViewModels here.

### Scenes/{ScreenName}

Each screen folder contains one ViewModel and one View (the primary view plus any sub-views or row views for the screen). The ViewModel is declared as `@Observable @MainActor final class`, and calls use cases. The View declares the ViewModel as `@State var viewModel: {Name}ViewModel`.
