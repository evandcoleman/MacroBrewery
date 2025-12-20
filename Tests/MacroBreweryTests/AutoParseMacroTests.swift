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
        "AutoParseable": AutoParseableAttribute.self,
    ]
    #endif

    // MARK: - Basic Parsing Tests

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
                @AutoParseable
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
                        cats: raw.cats.map {
                            .init($0)
                        }
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

    // MARK: - Access Level Tests

    func testAccessLevelPublic() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: UserDTO.self, accessLevel: "public")
            struct User {
                var name: String
                var age: Int
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String
                var age: Int
            }

            extension User: AutoParseable {
                public init(_ raw: UserDTO) {
                    self.init(
                        name: raw.name,
                        age: raw.age
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
            @AutoParse(from: UserDTO.self, accessLevel: "internal")
            public struct User {
                var name: String
            }
            """,
            expandedSource:
            """
            public struct User {
                var name: String
            }

            extension User: AutoParseable {
                internal init(_ raw: UserDTO) {
                    self.init(
                        name: raw.name
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
            @AutoParse(from: AnimalDTO.self)
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
            }

            extension Animal: AutoParseable {
                init(_ raw: AnimalDTO) {
                    self.init(
                        name: raw.name,
                        age: raw.age
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
            @AutoParse(from: StoreDTO.self)
            actor DataStore {
                var items: [String]
            }
            """,
            expandedSource:
            """
            actor DataStore {
                var items: [String]
            }

            extension DataStore: AutoParseable {
                init(_ raw: StoreDTO) {
                    self.init(
                        items: raw.items
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Property Variations

    func testOptionalProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: ProfileDTO.self)
            struct Profile {
                var name: String
                var bio: String?
                var website: URL?
            }
            """,
            expandedSource:
            """
            struct Profile {
                var name: String
                var bio: String?
                var website: URL?
            }

            extension Profile: AutoParseable {
                init(_ raw: ProfileDTO) {
                    self.init(
                        name: raw.name,
                        bio: raw.bio,
                        website: raw.website
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testArrayProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: TeamDTO.self)
            struct Team {
                var members: [String]
                var scores: [Int]
            }
            """,
            expandedSource:
            """
            struct Team {
                var members: [String]
                var scores: [Int]
            }

            extension Team: AutoParseable {
                init(_ raw: TeamDTO) {
                    self.init(
                        members: raw.members,
                        scores: raw.scores
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testDictionaryProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: SettingsDTO.self)
            struct Settings {
                var config: [String: Any]
            }
            """,
            expandedSource:
            """
            struct Settings {
                var config: [String: Any]
            }

            extension Settings: AutoParseable {
                init(_ raw: SettingsDTO) {
                    self.init(
                        config: raw.config
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Nested Parsing Tests

    func testNestedSingleObject() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: OrderDTO.self)
            struct Order {
                var id: String
                @AutoParseable
                var customer: Customer
            }
            """,
            expandedSource:
            """
            struct Order {
                var id: String
                var customer: Customer
            }

            extension Order: AutoParseable {
                init(_ raw: OrderDTO) {
                    self.init(
                        id: raw.id,
                        customer: raw.customer.map {
                            .init($0)
                        }
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testNestedArrayOfObjects() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: LibraryDTO.self)
            struct Library {
                var name: String
                @AutoParseable
                var books: [Book]
            }
            """,
            expandedSource:
            """
            struct Library {
                var name: String
                var books: [Book]
            }

            extension Library: AutoParseable {
                init(_ raw: LibraryDTO) {
                    self.init(
                        name: raw.name,
                        books: raw.books.map {
                            .init($0)
                        }
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Edge Cases

    func testSingleProperty() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: WrapperDTO.self)
            struct Wrapper {
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Wrapper {
                var value: Int
            }

            extension Wrapper: AutoParseable {
                init(_ raw: WrapperDTO) {
                    self.init(
                        value: raw.value
                    )
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testEmptyStruct() throws {
        #if canImport(MacroBreweryMacros)
        // Empty struct should not generate extension
        assertMacroExpansion(
            """
            @AutoParse(from: EmptyDTO.self)
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
            @AutoParse(from: ConfigDTO.self)
            struct Config {
                static var version: Int = 1
                var name: String
            }
            """,
            expandedSource:
            """
            struct Config {
                static var version: Int = 1
                var name: String
            }

            extension Config: AutoParseable {
                init(_ raw: ConfigDTO) {
                    self.init(
                        name: raw.name
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
            @AutoParse(from: RectDTO.self)
            struct Rect {
                var width: Int
                var height: Int
                var area: Int {
                    width * height
                }
            }
            """,
            expandedSource:
            """
            struct Rect {
                var width: Int
                var height: Int
                var area: Int {
                    width * height
                }
            }

            extension Rect: AutoParseable {
                init(_ raw: RectDTO) {
                    self.init(
                        width: raw.width,
                        height: raw.height
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
            @AutoParse(from: StatusDTO.self)
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
                DiagnosticSpec(message: "@AutoParse can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testProtocolNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoParse(from: DataDTO.self)
            protocol Parseable {
                var data: String { get }
            }
            """,
            expandedSource:
            """
            protocol Parseable {
                var data: String { get }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoParse can only be applied to classes, structs, and actors.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }
}
