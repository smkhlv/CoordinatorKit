# CoordinatorKit

A type-safe coordinator navigation library for SwiftUI using Swift macros, async/await, and Swift 6 concurrency.

## Features

- **Macro-powered** — `@Coordinator` generates all boilerplate
- **Type-safe routing** — enum-based routes with associated SwiftUI views
- **Unidirectional data flow** — views dispatch `Action`s, coordinator handles navigation
- **Modal support** — sheets and full-screen covers with interactive gesture control
- **Deep linking** — navigate to arbitrary paths programmatically
- **Swift 6 ready** — `@MainActor` isolation, `Sendable` conformance

## Requirements

- iOS 17+ / macOS 13+
- Swift 6.0+ (Xcode 16+)

## Installation

```swift
.package(url: "https://github.com/your-org/CoordinatorKit.git", from: "1.0.0")
```

Then add `CoordinatorKit` to your target's dependencies.

## Quick Start

### 1. Define routes

```swift
enum AppRoute: NavigationRoute {
    case home
    case detail(id: String)

    enum Action: Sendable {
        case openDetail(id: String)
        case goBack
    }

    @MainActor
    @ViewBuilder
    func build(actionDispatcher: ActionDispatcher<Action>) -> some View {
        switch self {
        case .home:
            HomeView(actionDispatcher: actionDispatcher)
        case .detail(let id):
            DetailView(id: id, actionDispatcher: actionDispatcher)
        }
    }
}
```

### 2. Create a coordinator

```swift
@Coordinator(AppRoute)
class AppCoordinator {
    func handle(_ action: AppRoute.Action) {
        switch action {
        case .openDetail(let id):
            tryPush(.detail(id: id))
        case .goBack:
            try? pop()
        }
    }
}
```

### 3. Use CoordinatorView

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: AppCoordinator(root: .home))
        }
    }
}
```

### 4. Dispatch actions from views

```swift
struct HomeView: View {
    let actionDispatcher: ActionDispatcher<AppRoute.Action>

    var body: some View {
        Button("Open Detail") {
            actionDispatcher.send(.openDetail(id: "42"))
        }
    }
}
```

## API Reference

### Navigation

| Method | Description |
|--------|-------------|
| `push(_ route)` | Push route onto stack (throws on overflow or validation failure) |
| `pop()` | Pop last route (throws if stack is empty) |
| `popToRoot()` | Clear navigation stack |
| `popTo(_ route)` | Pop to a specific route |
| `tryPush(_ route)` | Non-throwing push, returns `Bool` |
| `navigate(to: path)` | Deep link to a specific path |

### Presentation

| Method | Description |
|--------|-------------|
| `presentSheet(_ route)` | Present route as sheet |
| `presentFullScreen(_ route)` | Present route as full-screen cover |
| `dismissSheet()` | Dismiss active sheet |
| `dismissFullScreen()` | Dismiss active full-screen cover |
| `dismissAllPresentations()` | Dismiss all active presentations |
| `tryPresentSheet(_ route)` | Non-throwing sheet presentation |
| `tryPresentFullScreen(_ route)` | Non-throwing full-screen presentation |

### Root Management

| Method | Description |
|--------|-------------|
| `setRoot(_ route)` | Change root and clear stack |

### Interactive Gesture Hooks

Override these in your coordinator to control swipe gestures:

```swift
func canInteractiveNavigationPop(from route: Route) -> Bool { true }
func canInteractiveDismiss(for presentationType: PresentationType) -> Bool { true }
func validateNavigation(to newRoute: Route, from currentRoute: Route?) throws { }
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  CoordinatorView                │
│  NavigationStack ← navigationPath binding       │
│  .sheet ← presentationState binding            │
│  .fullScreenCover ← presentationState binding  │
└──────────────────────┬──────────────────────────┘
                       │ @StateObject
                       ▼
┌─────────────────────────────────────────────────┐
│                   Coordinator                   │
│  @Published navigationPath: [Route]             │
│  @Published presentationState                   │
│  @Published root: Route                         │
│  ActionDispatcher → handle(_ action:)           │
└──────────────────────┬──────────────────────────┘
                       │ build(actionDispatcher:)
                       ▼
┌─────────────────────────────────────────────────┐
│               NavigationRoute (enum)            │
│  case home, detail, settings...                 │
│  → SwiftUI View per case                        │
│  → Action enum                                  │
└─────────────────────────────────────────────────┘
```

## Debug Logging

```swift
CoordinatorDebugConfiguration.enable()  // in App.init
```

Outputs navigation events to OSLog (`subsystem: "com.coordinator"`).

## License

MIT
