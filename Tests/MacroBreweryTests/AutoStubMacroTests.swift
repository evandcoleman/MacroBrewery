import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class AutoStubMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "AutoStub": AutoStubMacro.self,
        "Stub": AutoStubAttribute.self,
    ]
    #endif

    // MARK: - Basic Stub Tests

    func testAccessLevelDefault() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            public struct Cat {
                @Stub(7)
                public var age: Int
                @Stub("Luna")
                public var name: String?
                @Stub(false)
                public var soft: Bool
                public var fuzzy: Bool = true
                @Stub(true)
                public var small: Bool = false
            }
            """,
            expandedSource:
            """
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true
                public var small: Bool = false

                public static func stub(
                    age: Int = 7,
                    name: String? = "Luna",
                    soft: Bool = false,
                    fuzzy: Bool = true,
                    small: Bool = true
                ) -> Cat {
                    Cat(
                        age: age,
                        name: name,
                        soft: soft,
                        fuzzy: fuzzy,
                        small: small
                    )
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
            @AutoStub(accessLevel: "public")
            struct User {
                @Stub("Test")
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String

                public static func stub(
                    name: String = "Test"
                ) -> User {
                    User(
                        name: name
                    )
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
            @AutoStub(accessLevel: "private")
            struct User {
                @Stub("Test")
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String

                private static func stub(
                    name: String = "Test"
                ) -> User {
                    User(
                        name: name
                    )
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
            @AutoStub
            class Animal {
                @Stub("Buddy")
                var name: String
                @Stub(5)
                var age: Int
            }
            """,
            expandedSource:
            """
            class Animal {
                var name: String
                var age: Int

                static func stub(
                    name: String = "Buddy",
                    age: Int = 5
                ) -> Animal {
                    Animal(
                        name: name,
                        age: age
                    )
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
            @AutoStub
            actor DataStore {
                @Stub([])
                var items: [String]
            }
            """,
            expandedSource:
            """
            actor DataStore {
                var items: [String]

                static func stub(
                    items: [String] = []
                ) -> DataStore {
                    DataStore(
                        items: items
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Stub Value Tests

    func testStubWithNestedType() throws {
        #if canImport(MacroBreweryMacros)
        // @Stub() without value calls .stub() on the nested type
        assertMacroExpansion(
            """
            @AutoStub
            struct Owner {
                @Stub()
                var pet: Pet
                @Stub("John")
                var name: String
            }
            """,
            expandedSource:
            """
            struct Owner {
                var pet: Pet
                var name: String

                static func stub(
                    pet: Pet = .stub(),
                    name: String = "John"
                ) -> Owner {
                    Owner(
                        pet: pet,
                        name: name
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testOptionalWithoutStub() throws {
        #if canImport(MacroBreweryMacros)
        // Optional properties without @Stub default to nil
        assertMacroExpansion(
            """
            @AutoStub
            struct User {
                @Stub("Test")
                var name: String
                var email: String?
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String
                var email: String?

                static func stub(
                    name: String = "Test",
                    email: String? = nil
                ) -> User {
                    User(
                        name: name,
                        email: email
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testDefaultValuePreserved() throws {
        #if canImport(MacroBreweryMacros)
        // Properties with default values use them as stub defaults
        assertMacroExpansion(
            """
            @AutoStub
            struct Config {
                var timeout: Int = 30
                var retries: Int = 3
            }
            """,
            expandedSource:
            """
            struct Config {
                var timeout: Int = 30
                var retries: Int = 3

                static func stub(
                    timeout: Int = 30,
                    retries: Int = 3
                ) -> Config {
                    Config(
                        timeout: timeout,
                        retries: retries
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testStubOverridesDefault() throws {
        #if canImport(MacroBreweryMacros)
        // @Stub value overrides the property's default value
        assertMacroExpansion(
            """
            @AutoStub
            struct Config {
                @Stub(60)
                var timeout: Int = 30
            }
            """,
            expandedSource:
            """
            struct Config {
                var timeout: Int = 30

                static func stub(
                    timeout: Int = 60
                ) -> Config {
                    Config(
                        timeout: timeout
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Property Type Tests

    func testArrayStubValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            struct Container {
                @Stub(["a", "b", "c"])
                var items: [String]
            }
            """,
            expandedSource:
            """
            struct Container {
                var items: [String]

                static func stub(
                    items: [String] = ["a", "b", "c"]
                ) -> Container {
                    Container(
                        items: items
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testDictionaryStubValue() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            struct Settings {
                @Stub(["key": "value"])
                var data: [String: String]
            }
            """,
            expandedSource:
            """
            struct Settings {
                var data: [String: String]

                static func stub(
                    data: [String: String] = ["key": "value"]
                ) -> Settings {
                    Settings(
                        data: data
                    )
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
        // No stored properties, no stub method generated
        assertMacroExpansion(
            """
            @AutoStub
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

    func testStaticPropertiesIgnored() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            struct WithStatic {
                static var shared: Int = 0
                @Stub("test")
                var name: String
            }
            """,
            expandedSource:
            """
            struct WithStatic {
                static var shared: Int = 0
                var name: String

                static func stub(
                    name: String = "test"
                ) -> WithStatic {
                    WithStatic(
                        name: name
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testComputedPropertiesIgnored() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            struct WithComputed {
                @Stub(10)
                var value: Int
                var doubled: Int {
                    value * 2
                }
            }
            """,
            expandedSource:
            """
            struct WithComputed {
                var value: Int
                var doubled: Int {
                    value * 2
                }

                static func stub(
                    value: Int = 10
                ) -> WithComputed {
                    WithComputed(
                        value: value
                    )
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
            @AutoStub
            struct Single {
                @Stub(42)
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Single {
                var value: Int

                static func stub(
                    value: Int = 42
                ) -> Single {
                    Single(
                        value: value
                    )
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
            @AutoStub
            enum Status {
                case active
            }
            """,
            expandedSource:
            """
            enum Status {
                case active
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoStub can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testProtocolNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub
            protocol Stubable {
                var name: String { get }
            }
            """,
            expandedSource:
            """
            protocol Stubable {
                var name: String { get }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoStub can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testStubOnNonProperty() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @Stub("test")
            func doSomething() {}
            """,
            expandedSource:
            """
            func doSomething() {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Stub can only be applied to properties.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelFileprivate() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoStub(accessLevel: "fileprivate")
            struct User {
                @Stub("Test")
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String

                fileprivate static func stub(
                    name: String = "Test"
                ) -> User {
                    User(
                        name: name
                    )
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
            @AutoStub(accessLevel: "internal")
            struct User {
                @Stub("Test")
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String

                internal static func stub(
                    name: String = "Test"
                ) -> User {
                    User(
                        name: name
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
