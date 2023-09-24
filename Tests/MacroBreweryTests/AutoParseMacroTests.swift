import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class AutoParseMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "AutoParse": AutoParseMacro.self,
    ]
    #endif

    func testPrimitives() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: CatDetails.self)
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
            }

            extension Cat: AutoParseable {
                public init(_ raw: CatDetails) {
                    self.init(
                        age: raw.age,
                        name: raw.name,
                        soft: raw.soft,
                        fuzzy: raw.fuzzy
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testNestedTypes() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: HouseholdDetails.self)
            struct Household {
                var cats: [Cat]
            }

            @AutoParse(from: CatDetails.self)
            struct Cat {
                var age: Int
                var name: String?
                var soft: Bool
                var fuzzy: Bool = true
            }
            """,
            expandedSource:
            """
            struct Household {
                var cats: [Cat]
            }
            struct Cat {
                var age: Int
                var name: String?
                var soft: Bool
                var fuzzy: Bool = true
            }

            extension Household: AutoParseable {
                init(_ raw: HouseholdDetails) {
                    self.init(
                        cats: raw.cats.map { Cat($0) }
                    )
                }
            }

            extension Cat: AutoParseable {
                init(_ raw: CatDetails) {
                    self.init(
                        age: raw.age,
                        name: raw.name,
                        soft: raw.soft,
                        fuzzy: raw.fuzzy
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
