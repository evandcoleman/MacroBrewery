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
            @AutoInit(accessLevel: .public)
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
            @AutoInit(accessLevel: .private)
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
            }
            """,
            expandedSource:
            """
            public struct Cat {
                public var age: Int
                public var name: String?
                public var soft: Bool
                public var fuzzy: Bool = true

                init(
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
}
