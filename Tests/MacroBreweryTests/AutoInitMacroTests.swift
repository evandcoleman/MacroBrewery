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

    func testEmptyStruct() throws {
        #if canImport(MacroBreweryMacros)
        // Empty struct has no stored properties, so no init is generated
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
        // No stored properties means no init is generated
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
        // Static properties should not be included in the initializer
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
}
