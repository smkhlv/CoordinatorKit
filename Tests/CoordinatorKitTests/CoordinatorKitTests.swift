import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CoordinatorKitMacros)
import CoordinatorKitMacros

let testMacros: [String: Macro.Type] = [
    "Coordinator": CoordinatorKit.self,
]
#endif

final class CoordinatorKitTests: XCTestCase {

    // MARK: - Macro Expansion Tests

    func testCoordinatorMacroExpansion() throws {
        #if canImport(CoordinatorKitMacros)
        assertMacroExpansion(
            """
            @Coordinator(MyRoute)
            class MyCoordinator {
            }
            """,
            expandedSource: """
            class MyCoordinator {

                @Published var root: MyRoute

                @Published var navigationPath: [MyRoute] = []

                @Published var presentationState = PresentationState<MyRoute>()

                let actionDispatcher = ActionDispatcher<MyRoute.Action>()

                var actionCancellables = Set<AnyCancellable>()

                init(root: MyRoute) {
                    self.root = root
                    bindActionDispatcher()
                }

                deinit {
                    // AnyCancellable automatically cancels when deallocated
                    #if DEBUG
                        print("🧹 MyRoute Coordinator deallocated")
                    #endif
                }
            }

            @MainActor extension MyCoordinator: Coordinator {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCoordinatorWithSelfSyntax() throws {
        #if canImport(CoordinatorKitMacros)
        assertMacroExpansion(
            """
            @Coordinator(MyRoute.self)
            class MyCoordinator {
            }
            """,
            expandedSource: """
            class MyCoordinator {

                @Published var root: MyRoute

                @Published var navigationPath: [MyRoute] = []

                @Published var presentationState = PresentationState<MyRoute>()

                let actionDispatcher = ActionDispatcher<MyRoute.Action>()

                var actionCancellables = Set<AnyCancellable>()

                init(root: MyRoute) {
                    self.root = root
                    bindActionDispatcher()
                }

                deinit {
                    // AnyCancellable automatically cancels when deallocated
                    #if DEBUG
                        print("🧹 MyRoute Coordinator deallocated")
                    #endif
                }
            }

            @MainActor extension MyCoordinator: Coordinator {
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMissingRouteArgumentThrowsError() throws {
        #if canImport(CoordinatorKitMacros)
        assertMacroExpansion(
            """
            @Coordinator
            class InvalidCoordinator {
            }
            """,
            expandedSource: """
            class InvalidCoordinator {
            }

            @MainActor extension InvalidCoordinator: Coordinator {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Coordinator macro requires a NavigationRoute type",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
