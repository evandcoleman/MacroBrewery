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

                #if DEBUG
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
                #endif
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
