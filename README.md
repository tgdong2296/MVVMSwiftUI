<div align="center">

<img src="github_assets/logo.png" alt="MVVMSwiftUI logo" width="180" />

# MVVMSwiftUI

A reference iOS application built with **SwiftUI**, demonstrating a clean, scalable
**MVVM + Clean Architecture** with FactoryKit DI, Moya networking, SwiftData persistence,
and a custom Coordinator-based navigation pattern.

[![Swift](https://img.shields.io/badge/Swift-6-orange.svg?logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26.0%2B-blue.svg?logo=apple)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-26%2B-147EFB.svg?logo=xcode)](https://developer.apple.com/xcode/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0A84FF.svg?logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Clean-success.svg)](#-architecture)

</div>

---

## ✨ Overview

MVVMSwiftUI is a sample app whose primary goal is the **architecture**, not the feature set.
It ships a small but complete set of flows — authentication (login, register, OTP-based
password reset), a GitHub repository search/list with pagination, a repository detail screen,
and settings/theming — wired together with strict layer boundaries so the structure can be
lifted into production projects.

### Features

- 🔐 **Authentication flow** — login, register, request OTP, verify OTP, reset password.
- 🔎 **GitHub repository search** — query the GitHub API with paginated, infinite-scroll results.
- 📄 **Repository detail** — drill into a selected repository.
- 🎨 **Theming** — light/dark/system themes driven by a single `ThemeStore` design-token source.
- 🧭 **Coordinator navigation** — type-safe, `NavigationStack`-driven routing, one coordinator per flow.
- 🧪 **Unit tests** — ViewModel coverage with Swift Testing and protocol-based mocks.
- 🧰 **Mockable networking** — JSON-stubbed endpoints for offline/dev runs.

---

## 🧱 Architecture

Three-layer Clean Architecture. **Dependencies always point inward:**

```
Scenes  ──►  Domain (UseCase)  ──►  Data (API / Local)
   │                                  ▲
   └──►  Application (Stores, Validations, Supports)
```

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Domain** | `Domain/` | Pure Swift — `Entities` (value types) + `UseCase`s (stateless business logic). Zero framework imports. |
| **Application** | `Application/` | Global `@Observable` stores (`AppStateStore`, `ThemeStore`), validations, and Swift/SwiftUI extensions. |
| **Data** | `Data/` | All I/O — Moya `APIService`, SwiftData `ContextStore`, `UserDefaultsService`, token lifecycle, and JSON mocks. |
| **Scenes** | `Scenes/` | SwiftUI `View`s, `@Observable` `ViewModel`s, and `Coordinator`s. No direct API access. |
| **Services** | `Services/` | Third-party SDK wrappers behind protocol interfaces. |

**Key principles:**

- **ViewModel as mediator** — ViewModels call Use Cases only, never services or API targets directly.
- **Use case = domain, not action** — a use case groups all related methods for a feature (e.g. `AuthUseCase`), not a single `execute(...)`.
- **Logic-free coordinators** — coordinators hold only their navigation `path`; no business logic, no feature state.
- **Composable loading state** — each async section owns a `ViewState`; the screen exposes a computed `viewState` via `combine([...])`.
- **DI everywhere** — every dependency is resolved through FactoryKit's `Container` against protocol types.

> 📖 The full conventions, gotchas, and layer rules live in [`CLAUDE.md`](CLAUDE.md).

---

## 📁 Project Structure

```
MVVMSwiftUI/
├── Domain/
│   ├── Entities/            # ViewState, AppFlow, AppTheme, GitHubRepo, …
│   └── UseCase/             # Auth, Config, GitHub — one subfolder per domain
├── Application/
│   ├── Aggregates/          # AppStateStore, ThemeStore (global singletons)
│   ├── Supports/            # Swift/SwiftUI extensions & utilities
│   └── Validations/         # @Validate + ValidationRule conformances
├── Data/
│   ├── API/
│   │   ├── Base/            # APIService, BaseTargetType, APIError, …
│   │   ├── Implementation/  # AuthAPI, GitHubAPI (Moya targets)
│   │   └── Token/           # TokenManager, TokenRefreshCoordinator
│   ├── Local/               # SwiftData (ContextStore) + UserDefaults
│   └── Mock/                # MockHelper + JSON stubs
├── Scenes/
│   ├── App/                 # Entry point + AppViewModel
│   ├── Navigation/          # Coordinators, Route, CoordinatorType
│   ├── Common/              # CommonContainerView, loading/error views
│   └── Home / Login / Register / ResetPassword / RepoDetail / Settings
├── Services/                # Firebase (protocol-wrapped) …
└── Environment/             # Development.xcconfig, Production.xcconfig, Environments.swift
```

---

## 🧩 Tech Stack

| Concern | Choice |
|---------|--------|
| UI | SwiftUI (iOS 26) |
| Architecture | MVVM + Clean Architecture |
| Dependency Injection | [FactoryKit (Factory)](https://github.com/hmlongco/Factory) |
| Networking | [Moya](https://github.com/Moya/Moya) (async/await wrapper) |
| Image loading | [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) |
| Local persistence | SwiftData + `UserDefaults` |
| Reactive utilities | [CombineCocoa](https://github.com/CombineCommunity/CombineCocoa), [CombineExt](https://github.com/CombineCommunity/CombineExt) |
| Linting | [SwiftLint](https://github.com/SimplyDanny/SwiftLintPlugins) (build-plugin, custom rules) |
| Testing | Swift Testing |

All dependencies are managed via **Swift Package Manager** (resolved automatically by Xcode).

---

## 🚀 Getting Started

### Requirements

- **Xcode 26** or newer
- **iOS 26.0** or newer (deployment target)
- macOS capable of running Xcode 26

### Setup

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd MVVMSwiftUI

# 2. Open the project (SPM dependencies resolve automatically)
open MVVMSwiftUI.xcodeproj
```

Then select the **MVVMSwiftUI** scheme and an iOS 26 simulator, and press **⌘R**.

### Build Configurations

The app reads runtime config from `.xcconfig` files via `Environments.swift` (backed by `Info.plist`):

| Config | `IS_DEV` | Behavior |
|--------|----------|----------|
| `Development.xcconfig` | `YES` | Enables dev-gated mock API responses |
| `Production.xcconfig` | `NO` | Hits live endpoints |

> Mock behavior is driven by the `IS_DEV` build setting (not the scheme name). Each API target
> supplies its mock through `sampleData`; always-stubbed targets serve JSON from `Data/Mock/`
> regardless of the flag.

---

## 🧪 Testing

ViewModels are covered with **Swift Testing** and protocol-based mock use cases.

```bash
# Run all tests from the command line
xcodebuild test \
  -project MVVMSwiftUI.xcodeproj \
  -scheme MVVMSwiftUI \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Or simply press **⌘U** in Xcode.

---

## 🧹 Linting

SwiftLint runs as a build plugin and enforces custom rules (e.g. `final_class`, no force-unwrapping).

```bash
# Lint
swiftlint lint

# Auto-fix
swiftlint --fix
```

---

## 🤝 Contributing

Before opening a PR, please:

1. Follow the architecture and conventions documented in [`CLAUDE.md`](CLAUDE.md).
2. Update `Localizable.xcstrings` when adding/editing/removing user-facing strings.
3. Ensure `swiftlint lint` passes with zero violations.
4. Ensure the project builds and tests pass.

---

<div align="center">

Built with ❤️ using SwiftUI &amp; Clean Architecture.

</div>
