import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class TestEachMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "testEach": TestEachMacro.self,
    ]
    #endif

    func testIntegers() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            func testCatsAreSoft() {
                #testEach([1, 2, 3]) { index in
                    let cat = cats[index]
                    XCTAssertTrue(cat.soft)
                }
            }
            """,
            expandedSource:
            """
            func testCatsAreSoft() {
                let performTest = { index in
                    let cat = cats[index]
                    XCTAssertTrue(cat.soft)
                }
                XCTContext.runActivity(named: String(describing: 1)) { _ in
                    performTest(1)
                }
                XCTContext.runActivity(named: String(describing: 2)) { _ in
                    performTest(2)
                }
                XCTContext.runActivity(named: String(describing: 3)) { _ in
                    performTest(3)
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testStrings() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            func testCatsAreSoft() {
                #testEach(["Luna", "Leo", "Oliver"]) { name in
                    let cat = cats.named(name)
                    XCTAssertTrue(cat.soft)
                }
            }
            """,
            expandedSource:
            """
            func testCatsAreSoft() {
                let performTest = { name in
                    let cat = cats.named(name)
                    XCTAssertTrue(cat.soft)
                }
                XCTContext.runActivity(named: String(describing: "Luna")) { _ in
                    performTest("Luna")
                }
                XCTContext.runActivity(named: String(describing: "Leo")) { _ in
                    performTest("Leo")
                }
                XCTContext.runActivity(named: String(describing: "Oliver")) { _ in
                    performTest("Oliver")
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
