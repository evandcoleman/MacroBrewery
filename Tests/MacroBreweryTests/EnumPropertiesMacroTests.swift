import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class EnumPropertiesMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "EnumProperties": EnumPropertiesMacro.self,
    ]
    #endif

    // MARK: - Basic Enum Properties Tests

    func testSimpleCases() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Status {
                case idle
                case loading
                case loaded
            }
            """,
            expandedSource:
            """
            enum Status {
                case idle
                case loading
                case loaded

                var isIdle: Bool {
                    if case .idle = self {
                        return true
                    }
                    return false
                }

                var isLoading: Bool {
                    if case .loading = self {
                        return true
                    }
                    return false
                }

                var isLoaded: Bool {
                    if case .loaded = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testSingleAssociatedValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Result {
                case success(data: Data)
                case failure(error: Error)
            }
            """,
            expandedSource:
            """
            enum Result {
                case success(data: Data)
                case failure(error: Error)

                var isSuccess: Bool {
                    if case .success = self {
                        return true
                    }
                    return false
                }

                var success: Data? {
                    if case .success(let data) = self {
                        return data
                    }
                    return nil
                }

                var isFailure: Bool {
                    if case .failure = self {
                        return true
                    }
                    return false
                }

                var failure: Error? {
                    if case .failure(let error) = self {
                        return error
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMultipleAssociatedValues() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum LoadingState {
                case loading(progress: Double, message: String)
            }
            """,
            expandedSource:
            """
            enum LoadingState {
                case loading(progress: Double, message: String)

                var isLoading: Bool {
                    if case .loading = self {
                        return true
                    }
                    return false
                }

                var loading: (progress: Double, message: String)? {
                    if case .loading(let progress, let message) = self {
                        return (progress, message)
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testUnlabeledAssociatedValues() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Container {
                case single(Int)
                case pair(String, Int)
            }
            """,
            expandedSource:
            """
            enum Container {
                case single(Int)
                case pair(String, Int)

                var isSingle: Bool {
                    if case .single = self {
                        return true
                    }
                    return false
                }

                var single: Int? {
                    if case .single(let value) = self {
                        return value
                    }
                    return nil
                }

                var isPair: Bool {
                    if case .pair = self {
                        return true
                    }
                    return false
                }

                var pair: (String, Int)? {
                    if case .pair(let v0, let v1) = self {
                        return (v0, v1)
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMixedLabeledUnlabeled() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Event {
                case tap(x: Int, _ y: Int)
            }
            """,
            expandedSource:
            """
            enum Event {
                case tap(x: Int, _ y: Int)

                var isTap: Bool {
                    if case .tap = self {
                        return true
                    }
                    return false
                }

                var tap: (x: Int, Int)? {
                    if case .tap(let x, let v1) = self {
                        return (x, v1)
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Access Level Tests

    func testAccessLevelPublic() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties(accessLevel: "public")
            enum State {
                case on
                case off
            }
            """,
            expandedSource:
            """
            enum State {
                case on
                case off

                public var isOn: Bool {
                    if case .on = self {
                        return true
                    }
                    return false
                }

                public var isOff: Bool {
                    if case .off = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelInternal() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties(accessLevel: "internal")
            enum Toggle {
                case enabled
                case disabled
            }
            """,
            expandedSource:
            """
            enum Toggle {
                case enabled
                case disabled

                internal var isEnabled: Bool {
                    if case .enabled = self {
                        return true
                    }
                    return false
                }

                internal var isDisabled: Bool {
                    if case .disabled = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelPrivate() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties(accessLevel: "private")
            enum Mode {
                case light
                case dark
            }
            """,
            expandedSource:
            """
            enum Mode {
                case light
                case dark

                private var isLight: Bool {
                    if case .light = self {
                        return true
                    }
                    return false
                }

                private var isDark: Bool {
                    if case .dark = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelInheritsFromDeclaration() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            public enum PublicState {
                case active
                case inactive
            }
            """,
            expandedSource:
            """
            public enum PublicState {
                case active
                case inactive

                public var isActive: Bool {
                    if case .active = self {
                        return true
                    }
                    return false
                }

                public var isInactive: Bool {
                    if case .inactive = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Edge Cases

    func testEmptyEnum() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Empty {
            }
            """,
            expandedSource:
            """
            enum Empty {
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testSingleCase() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Singleton {
                case instance
            }
            """,
            expandedSource:
            """
            enum Singleton {
                case instance

                var isInstance: Bool {
                    if case .instance = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMultipleCasesOnSameLine() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Direction {
                case north, south, east, west
            }
            """,
            expandedSource:
            """
            enum Direction {
                case north, south, east, west

                var isNorth: Bool {
                    if case .north = self {
                        return true
                    }
                    return false
                }

                var isSouth: Bool {
                    if case .south = self {
                        return true
                    }
                    return false
                }

                var isEast: Bool {
                    if case .east = self {
                        return true
                    }
                    return false
                }

                var isWest: Bool {
                    if case .west = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMixedCasesWithAndWithoutAssociatedValues() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum NetworkState {
                case idle
                case loading
                case success(data: Data)
                case failure(error: Error)
            }
            """,
            expandedSource:
            """
            enum NetworkState {
                case idle
                case loading
                case success(data: Data)
                case failure(error: Error)

                var isIdle: Bool {
                    if case .idle = self {
                        return true
                    }
                    return false
                }

                var isLoading: Bool {
                    if case .loading = self {
                        return true
                    }
                    return false
                }

                var isSuccess: Bool {
                    if case .success = self {
                        return true
                    }
                    return false
                }

                var success: Data? {
                    if case .success(let data) = self {
                        return data
                    }
                    return nil
                }

                var isFailure: Bool {
                    if case .failure = self {
                        return true
                    }
                    return false
                }

                var failure: Error? {
                    if case .failure(let error) = self {
                        return error
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testGenericAssociatedValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Optional<T> {
                case some(T)
                case none
            }
            """,
            expandedSource:
            """
            enum Optional<T> {
                case some(T)
                case none

                var isSome: Bool {
                    if case .some = self {
                        return true
                    }
                    return false
                }

                var some: T? {
                    if case .some(let value) = self {
                        return value
                    }
                    return nil
                }

                var isNone: Bool {
                    if case .none = self {
                        return true
                    }
                    return false
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Error Diagnostics

    func testStructNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            struct User {
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@EnumProperties can only be applied to enums.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testClassNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            class Animal {
                var name: String
            }
            """,
            expandedSource:
            """
            class Animal {
                var name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@EnumProperties can only be applied to enums.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testActorNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            actor DataStore {
                var items: [String]
            }
            """,
            expandedSource:
            """
            actor DataStore {
                var items: [String]
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@EnumProperties can only be applied to enums.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testProtocolNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            protocol Stateful {
                var state: Int { get }
            }
            """,
            expandedSource:
            """
            protocol Stateful {
                var state: Int { get }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@EnumProperties can only be applied to enums.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    // MARK: - Complex Associated Values

    func testTupleAssociatedValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Coordinate {
                case point(x: Int, y: Int, z: Int)
            }
            """,
            expandedSource:
            """
            enum Coordinate {
                case point(x: Int, y: Int, z: Int)

                var isPoint: Bool {
                    if case .point = self {
                        return true
                    }
                    return false
                }

                var point: (x: Int, y: Int, z: Int)? {
                    if case .point(let x, let y, let z) = self {
                        return (x, y, z)
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testClosureAssociatedValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @EnumProperties
            enum Action {
                case perform(handler: () -> Void)
            }
            """,
            expandedSource:
            """
            enum Action {
                case perform(handler: () -> Void)

                var isPerform: Bool {
                    if case .perform = self {
                        return true
                    }
                    return false
                }

                var perform: () -> Void? {
                    if case .perform(let handler) = self {
                        return handler
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
