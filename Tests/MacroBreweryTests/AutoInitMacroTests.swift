import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class AutoInitMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "AutoInit": AutoInitMacro.self,
    ]
    #endif

    // MARK: - Access Level Tests

    func testAccessLevelPublic() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit(accessLevel: "public")
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true
            }
            """,
            expandedSource:
            """
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true

                public init(
                    age: Int,
                    name: String? = nil,
                    soft: Bool,
                    fuzzy: Bool = true
                ) {
                    self.age = age
                    self.name = name
                    self.soft = soft
                    self.fuzzy = fuzzy
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
            @AutoInit(accessLevel: "private")
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true
            }
            """,
            expandedSource:
            """
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true

                private init(
                    age: Int,
                    name: String? = nil,
                    soft: Bool,
                    fuzzy: Bool = true
                ) {
                    self.age = age
                    self.name = name
                    self.soft = soft
                    self.fuzzy = fuzzy
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
            @AutoInit(accessLevel: "internal")
            public struct Cat {
                var age: Int
            }
            """,
            expandedSource:
            """
            public struct Cat {
                var age: Int

                internal init(
                    age: Int
                ) {
                    self.age = age
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelFileprivate() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit(accessLevel: "fileprivate")
            struct Cat {
                var age: Int
            }
            """,
            expandedSource:
            """
            struct Cat {
                var age: Int

                fileprivate init(
                    age: Int
                ) {
                    self.age = age
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelDefault() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true

                public var isSoftAndFuzzy: Bool {
                    return soft && fuzzy
                }
            }
            """,
            expandedSource:
            """
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true

                public var isSoftAndFuzzy: Bool {
                    return soft && fuzzy
                }

                public init(
                    age: Int,
                    name: String? = nil,
                    soft: Bool,
                    fuzzy: Bool = true
                ) {
                    self.age = age
                    self.name = name
                    self.soft = soft
                    self.fuzzy = fuzzy
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Declaration Type Tests

    func testClass() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            class Animal {
                var name: String
                var age: Int
            }
            """,
            expandedSource:
            """
            class Animal {
                var name: String
                var age: Int

                init(
                    name: String,
                    age: Int
                ) {
                    self.name = name
                    self.age = age
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testActor() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            actor DataManager {
                var items: [String]
                var count: Int
            }
            """,
            expandedSource:
            """
            actor DataManager {
                var items: [String]
                var count: Int

                init(
                    items: [String],
                    count: Int
                ) {
                    self.items = items
                    self.count = count
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Property Variation Tests

    func testLetProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct User {
                let id: UUID
                let name: String
            }
            """,
            expandedSource:
            """
            struct User {
                let id: UUID
                let name: String

                init(
                    id: UUID,
                    name: String
                ) {
                    self.id = id
                    self.name = name
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMixedLetVar() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct User {
                let id: UUID
                var name: String
                let createdAt: Date
                var updatedAt: Date?
            }
            """,
            expandedSource:
            """
            struct User {
                let id: UUID
                var name: String
                let createdAt: Date
                var updatedAt: Date?

                init(
                    id: UUID,
                    name: String,
                    createdAt: Date,
                    updatedAt: Date? = nil
                ) {
                    self.id = id
                    self.name = name
                    self.createdAt = createdAt
                    self.updatedAt = updatedAt
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testGenericTypes() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Container<T> {
                var value: T
                var items: [T]
                var mapping: [String: T]
            }
            """,
            expandedSource:
            """
            struct Container<T> {
                var value: T
                var items: [T]
                var mapping: [String: T]

                init(
                    value: T,
                    items: [T],
                    mapping: [String: T]
                ) {
                    self.value = value
                    self.items = items
                    self.mapping = mapping
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testClosureProperty() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Handler {
                var onComplete: () -> Void
                var onError: (Error) -> Void
            }
            """,
            expandedSource:
            """
            struct Handler {
                var onComplete: () -> Void
                var onError: (Error) -> Void

                init(
                    onComplete: () -> Void,
                    onError: (Error) -> Void
                ) {
                    self.onComplete = onComplete
                    self.onError = onError
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testOptionalWithDefault() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Config {
                var timeout: Int = 30
                var retries: Int? = 3
                var label: String?
            }
            """,
            expandedSource:
            """
            struct Config {
                var timeout: Int = 30
                var retries: Int? = 3
                var label: String?

                init(
                    timeout: Int = 30,
                    retries: Int? = 3,
                    label: String? = nil
                ) {
                    self.timeout = timeout
                    self.retries = retries
                    self.label = label
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Edge Cases

    func testEmptyStruct() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Empty {
            }
            """,
            expandedSource:
            """
            struct Empty {
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testOnlyComputedProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Computed {
                var doubled: Int {
                    return 2
                }
            }
            """,
            expandedSource:
            """
            struct Computed {
                var doubled: Int {
                    return 2
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testStaticPropertiesIgnored() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct WithStatic {
                static var shared: Int = 0
                var name: String
            }
            """,
            expandedSource:
            """
            struct WithStatic {
                static var shared: Int = 0
                var name: String

                init(
                    name: String
                ) {
                    self.name = name
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testLazyPropertiesIncluded() throws {
        #if canImport(MacroBreweryMacros)
        // Lazy properties are included in the initializer with their default values
        assertMacroExpansion(
            """
            @AutoInit
            struct WithLazy {
                lazy var computed: Int = 42
                var name: String
            }
            """,
            expandedSource:
            """
            struct WithLazy {
                lazy var computed: Int = 42
                var name: String

                init(
                    computed: Int = 42,
                    name: String
                ) {
                    self.computed = computed
                    self.name = name
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testSingleProperty() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            struct Single {
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Single {
                var value: Int

                init(
                    value: Int
                ) {
                    self.value = value
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Error Diagnostics

    func testEnumNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            enum Status {
                case active
                case inactive
            }
            """,
            expandedSource:
            """
            enum Status {
                case active
                case inactive
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoInit can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testProtocolNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoInit
            protocol Describable {
                var description: String { get }
            }
            """,
            expandedSource:
            """
            protocol Describable {
                var description: String { get }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoInit can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }
}
