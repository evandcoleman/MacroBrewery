import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class AutoTypeEraseMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "AutoTypeErase": AutoTypeEraseMacro.self,
    ]
    #endif

    func testAccessLevelDefault() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            public protocol Animal {
                var age: Int { get }
                var name: String? { get }
                var soft: Bool { get }

                func pet() async throws
                func feed(_ completion: @escaping () -> Void) -> Result
            }
            """,
            expandedSource:
            """
            public protocol Animal {
                var age: Int { get }
                var name: String? { get }
                var soft: Bool { get }

                func pet() async throws
                func feed(_ completion: @escaping () -> Void) -> Result
            }

            public struct AnyAnimal: Animal {
                public let age: Int
                public let name: String?
                public let soft: Bool

                private let _pet: () async throws -> Void
                private let _feed: (_ completion: @escaping () -> Void) -> Result

                public init<T: Animal>(_ base: T) {
                    self.age = base.age
                    self.name = base.name
                    self.soft = base.soft

                    self._pet = base.pet
                    self._feed = base.feed
                }

                public func pet() async throws {
                    try await _pet()
                }

                public func feed(_ completion: @escaping () -> Void) -> Result {
                    _feed(completion)
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
