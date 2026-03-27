# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

```bash
# Build the package
swift build

# Run all tests
swift test

# Run a single test
swift test --filter CoordinatorKitTests/testCoordinatorMacroExpansion

# Build the Example app (from repo root)
xcodebuild -project Example/CoordinatorKitExample.xcodeproj \
           -scheme CoordinatorKitExample \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build
```

## Architecture

Three-layer design:

**Routes** (`NavigationRoute`) — enum cases that produce SwiftUI views and emit `Action` values. Each route builds its own view via `build(actionDispatcher:)`. Routes must be `Hashable`, `Identifiable`, and `Sendable`.

**Coordinator** (`Coordinator` protocol + `@Coordinator` macro) — `@MainActor ObservableObject` owning the navigation state (`navigationPath`, `presentationState`, `root`). Handles all navigation operations. Actions from views arrive via `ActionDispatcher` through a Combine `PassthroughSubject`; `handle(_ action:)` translates them into navigation calls.

**CoordinatorView** — SwiftUI container wrapping a `NavigationStack` that intercepts its path binding to detect user-initiated swipe-back and swipe-to-dismiss gestures before forwarding them to the coordinator.

### Macro: `@Coordinator(RouteType)`

Applied to a class. Generates all stored properties (`root`, `navigationPath`, `presentationState`, `actionDispatcher`, `actionCancellables`), `init(root:)`, `deinit`, and an `@MainActor extension ClassName: Coordinator {}`.

- Declaration: `Sources/CoordinatorKit/CoordinatorKit.swift`
- Implementation: `Sources/CoordinatorKitMacros/CoordinatorKitMacro.swift`

### Key Files

- `Sources/CoordinatorKit/Coordinator.swift` — all protocols, types, and default extension implementations
- `Sources/CoordinatorKitMacros/CoordinatorKitMacro.swift` — `@Coordinator` macro expansion logic and `@main` compiler plugin
- `Tests/CoordinatorKitTests/CoordinatorKitTests.swift` — macro expansion tests; run them once after any macro changes to verify the `expandedSource` strings still match
- `Example/CoordinatorKitExample/ContentView.swift` — demo showing full usage pattern with push, pop, sheet presentation

### Swift 6 / Concurrency

All coordinator operations are `@MainActor`-isolated. `NavigationRoute` and its `Action` type must be `Sendable`. `@preconcurrency @_exported import Combine` in `Coordinator.swift` re-exports Combine to consumers and suppresses sendability warnings on `AnyCancellable`.

### Navigation Constraints

Default max stack depth: 20 (override `maxNavigationDepth` computed property). Only one modal (sheet or full-screen) can be active at a time — attempting to present while one is active throws `CoordinatorError.presentationConflict`. Consecutive duplicate pushes are silently ignored. Override `validateNavigation(to:from:)` to add custom navigation guards.

### Interactive Gesture Handling

`CoordinatorView` intercepts the `NavigationStack` path binding and the sheet/fullScreenCover `item` bindings. When SwiftUI sets them to `nil` (swipe gesture), the binding's `set` closure calls `canInteractiveNavigationPop` or `canInteractiveDismiss` before forwarding to the coordinator. Interactive dismissal uses a 150ms `Task.sleep` to let the animation complete before clearing state.

### Macro Tests Note

`assertMacroExpansion` in `CoordinatorKitTests` compares output character-by-character. If macro generation changes, run `swift test` once, read the failure message to get the exact actual output, then update `expandedSource` accordingly.
