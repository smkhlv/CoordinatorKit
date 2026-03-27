import SwiftUI
import CoordinatorKit

// MARK: - Routes

enum AppRoute: NavigationRoute {
    case home
    case detail(title: String)
    case settings

    enum Action: Sendable {
        case openDetail(title: String)
        case openSettings
        case goBack
        case goHome
    }

    @MainActor
    @ViewBuilder
    func build(actionDispatcher: ActionDispatcher<Action>) -> some View {
        switch self {
        case .home:
            HomeView(actionDispatcher: actionDispatcher)
        case .detail(let title):
            DetailView(title: title, actionDispatcher: actionDispatcher)
        case .settings:
            SettingsView(actionDispatcher: actionDispatcher)
        }
    }
}

// MARK: - Coordinator

@Coordinator(AppRoute)
class AppCoordinator {
    func handle(_ action: AppRoute.Action) {
        switch action {
        case .openDetail(let title):
            tryPush(.detail(title: title))
        case .openSettings:
            try? presentSheet(.settings)
        case .goBack:
            try? pop()
        case .goHome:
            popToRoot()
        }
    }
}

// MARK: - Views

struct HomeView: View {
    let actionDispatcher: ActionDispatcher<AppRoute.Action>

    var body: some View {
        VStack(spacing: 20) {
            Text("Home")
                .font(.largeTitle.bold())

            Button("Open Detail") {
                actionDispatcher.send(.openDetail(title: "My Detail"))
            }
            .buttonStyle(.borderedProminent)

            Button("Open Settings") {
                actionDispatcher.send(.openSettings)
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("Home")
    }
}

struct DetailView: View {
    let title: String
    let actionDispatcher: ActionDispatcher<AppRoute.Action>

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title.bold())

            Button("Go Back") {
                actionDispatcher.send(.goBack)
            }
            .buttonStyle(.bordered)

            Button("Go Home") {
                actionDispatcher.send(.goHome)
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle(title)
    }
}

struct SettingsView: View {
    let actionDispatcher: ActionDispatcher<AppRoute.Action>

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title.bold())

                Button("Close") {
                    actionDispatcher.send(.goBack)
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Entry Point

struct ContentView: View {
    var body: some View {
        CoordinatorView(coordinator: AppCoordinator(root: .home))
    }
}

#Preview {
    ContentView()
}
