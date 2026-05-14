# Project Structure

## Directory Tree

```
{AppName}/
├── {AppName}App.swift                # App entry point — injects global stores
├── AppDelegate.swift                 # UIApplicationDelegate
├── Info.plist
│
├── Domain/                           # Pure Swift — zero framework dependencies
│   ├── Entities/                     # Value types: Identifiable, Hashable, Codable, Sendable
│   │   ├── AppTheme.swift            # Theme definition (light/dark/system)
│   │   ├── ViewState.swift           # .indie | .loading | .success | .error(String)
│   │   ├── {Name}.swift
│   │   └── {Name}.swift
│   └── UseCase/                      # One subfolder per feature domain
│       ├── {Feature}/
│       │   └── {Name}UseCase.swift
│       └── {Feature}/
│           └── {Name}UseCase.swift
│
├── Application/                      # Cross-cutting app-layer concerns
│   ├── Aggregates/                   # Global app-level stores only
│   │   ├── {Name}Store.swift         
│   │   └── ThemeStore.swift          # Color scheme management, persisted via UserDefaults
│   ├── Supports/                     # Swift/SwiftUI extensions and utilities
│   └── Validations/                  # Validation Rules and Validators
│
├── Data/                             # Infrastructure: network, storage, mocks
│   ├── API/
│   │   ├── Base/                     # Shared networking primitives
│   │   │   ├── BaseTargetType.swift  # Moya TargetType extension
│   │   │   ├── APIService.swift      # Generic async/await request executor
│   │   │   ├── APIContainer.swift    # Factory registration helpers
│   │   │   ├── APIError.swift        # Typed error enum
│   │   │   ├── APIErrorParser.swift
│   │   │   └── APIResponse.swift     # Generic wrapped response type
│   │   ├── Implementation/           # Feature-specific Moya targets
│   │   │   ├── {Feature}API.swift
│   │   │   └── {Feature}API.swift
│   │   └── Token/                    # JWT lifecycle management
│   ├── Local/
│   │   ├── SwiftData/                # Storage data in local with SwiftDate
│   │   └── UserDefaults/             # Storage data in local with UserDefault
│   └── Mock/                         # JSON stubs for IS_DEV stub mode
│       ├── MockHelper.swift
│       ├── {Name}.json
│       └── {Name}.json
│
├── Scenes/                           # SwiftUI views, ViewModels, and coordinators
│   ├── App/
│   │   └── {AppName}App.swift        # Root scene switcher (auth vs. main flow)
│   ├── Navigation/                   # Coordinator infrastructure
│   ├── Common/                       # Reusable UI components
│   ├── {ScreenName}/                 # One folder per screen or screen group
│   │   ├── {ScreenName}View.swift    # SwiftUI view
│   │   └── {ScreenName}ViewModel.swift  # @Observable ViewModel
│   ├── {ScreenName}/
│   │   ├── {ScreenName}View.swift
│   │   └── {ScreenName}ViewModel.swift
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
|-------|--------|----------|
| **Domain** | `Domain/` | Pure Swift — no libraries and SDK imports |
| **Application** | `Application/` | Global stores, extensions, validations — no network calls |
| **Data** | `Data/` | All I/O data sources: API, SwiftData, UserDefaults, mocks |
| **Scenes** | `Scenes/` | SwiftUI views + ViewModels + coordinators — no direct API access |
| **Services** | `Services/` | Third-party SDK wrappers behind protocol interfaces |

### Domain/Entities

Declared in `Domain/Entities/`. Pure Swift value types — no frameworks and libraries. Conform to `Identifiable, Hashable, Codable, Sendable`. Provide `static let samples` in an extension for previews.

### Domain/UseCase

Declared in `Domain/UseCase/{Feature}/`. One file per use-case group. Contains the business logic that orchestrates API calls and domain transformations, domain business logic. Stateless — no `@Observable`, no stored mutable state.

### Application/Aggregates

Global state for app, any component can observe, singleton stores injected as `@environment` into the view hierarchy from the app entry point. Do **not** add feature-specific ViewModels here.

### Scenes/{FeatureName}

Each screen folder contains exactly one View + one ViewModel. The ViewModel is declared as `@Observable @MainActor final class`, and calls use cases. The View declares the ViewModel as `@State var viewModel: {Name}ViewModel`.
