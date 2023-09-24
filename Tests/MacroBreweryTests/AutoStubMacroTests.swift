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
                @Stub(7)
                public var age: Int
                @Stub("Luna")
                public var name: String?
                @Stub(false)
                public var soft: Bool
                public var fuzzy: Bool = true
                @Stub(true)
                public var small: Bool = false

                static func stub(
                    age: Int = 7,
                    name: String? = "Luna",
                    soft: Bool = false,
                    fuzzy: Bool = true,
                    small: Bool = true
                ) -> Cat {
                    self.age = age
                    self.name = name
                    self.soft = soft
                    self.fuzzy = fuzzy
                    self.small = small
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
