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

    // MARK: - Basic Type Erasure Tests

    func testBasicProtocol() throws {
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

    // MARK: - Access Level Tests

    func testAccessLevelPublic() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase("public")
            protocol Service {
                var id: String { get }
            }
            """,
            expandedSource:
            """
            protocol Service {
                var id: String { get }
            }

            public struct AnyService: Service {
                public let id: String



                public init<T: Service>(_ base: T) {
                    self.id = base.id


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
            @AutoTypeErase("private")
            protocol Handler {
                var name: String { get }
            }
            """,
            expandedSource:
            """
            protocol Handler {
                var name: String { get }
            }

            private struct AnyHandler: Handler {
                private let name: String



                private init<T: Handler>(_ base: T) {
                    self.name = base.name


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
            @AutoTypeErase("internal")
            public protocol Repository {
                var data: String { get }
            }
            """,
            expandedSource:
            """
            public protocol Repository {
                var data: String { get }
            }

            internal struct AnyRepository: Repository {
                internal let data: String



                internal init<T: Repository>(_ base: T) {
                    self.data = base.data


                }


            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAccessLevelInheritsFromProtocol() throws {
        #if canImport(MacroBreweryMacros)
        // When no access level specified, inherits from protocol
        assertMacroExpansion(
            """
            @AutoTypeErase
            public protocol PublicService {
                var id: String { get }
            }
            """,
            expandedSource:
            """
            public protocol PublicService {
                var id: String { get }
            }

            public struct AnyPublicService: PublicService {
                public let id: String



                public init<T: PublicService>(_ base: T) {
                    self.id = base.id


                }


            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Properties Only Tests

    func testPropertiesOnly() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol DataSource {
                var items: [String] { get }
                var count: Int { get }
                var isEmpty: Bool { get }
            }
            """,
            expandedSource:
            """
            protocol DataSource {
                var items: [String] { get }
                var count: Int { get }
                var isEmpty: Bool { get }
            }

            struct AnyDataSource: DataSource {
                let items: [String]
                let count: Int
                let isEmpty: Bool



                init<T: DataSource>(_ base: T) {
                    self.items = base.items
                    self.count = base.count
                    self.isEmpty = base.isEmpty


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
            @AutoTypeErase
            protocol Identifiable {
                var id: UUID { get }
            }
            """,
            expandedSource:
            """
            protocol Identifiable {
                var id: UUID { get }
            }

            struct AnyIdentifiable: Identifiable {
                let id: UUID



                init<T: Identifiable>(_ base: T) {
                    self.id = base.id


                }


            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Functions Only Tests

    func testFunctionsOnlyNoTypeErasure() throws {
        #if canImport(MacroBreweryMacros)
        // When there are no properties, no type erasure is generated
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Runnable {
                func run()
            }
            """,
            expandedSource:
            """
            protocol Runnable {
                func run()
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Function Signature Tests

    func testAsyncFunction() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Fetcher {
                var url: URL { get }
                func fetch() async -> Data
            }
            """,
            expandedSource:
            """
            protocol Fetcher {
                var url: URL { get }
                func fetch() async -> Data
            }

            struct AnyFetcher: Fetcher {
                let url: URL

                private let _fetch: () async  -> Data

                init<T: Fetcher>(_ base: T) {
                    self.url = base.url

                    self._fetch = base.fetch
                }

                func fetch() async -> Data {
                    await _fetch()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testThrowingFunction() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Parser {
                var format: String { get }
                func parse() throws -> Document
            }
            """,
            expandedSource:
            """
            protocol Parser {
                var format: String { get }
                func parse() throws -> Document
            }

            struct AnyParser: Parser {
                let format: String

                private let _parse: () throws  -> Document

                init<T: Parser>(_ base: T) {
                    self.format = base.format

                    self._parse = base.parse
                }

                func parse() throws -> Document {
                    try _parse()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testAsyncThrowingFunction() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol NetworkService {
                var baseURL: URL { get }
                func request() async throws -> Response
            }
            """,
            expandedSource:
            """
            protocol NetworkService {
                var baseURL: URL { get }
                func request() async throws -> Response
            }

            struct AnyNetworkService: NetworkService {
                let baseURL: URL

                private let _request: () async throws  -> Response

                init<T: NetworkService>(_ base: T) {
                    self.baseURL = base.baseURL

                    self._request = base.request
                }

                func request() async throws -> Response {
                    try await _request()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testFunctionWithParameters() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Calculator {
                var precision: Int { get }
                func add(a: Int, b: Int) -> Int
            }
            """,
            expandedSource:
            """
            protocol Calculator {
                var precision: Int { get }
                func add(a: Int, b: Int) -> Int
            }

            struct AnyCalculator: Calculator {
                let precision: Int

                private let _add: (_ a: Int, _ b: Int) -> Int

                init<T: Calculator>(_ base: T) {
                    self.precision = base.precision

                    self._add = base.add
                }

                func add(a: Int, b: Int) -> Int {
                    _add(a, b)
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testFunctionWithUnderscoreParameter() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Logger {
                var level: Int { get }
                func log(_ message: String)
            }
            """,
            expandedSource:
            """
            protocol Logger {
                var level: Int { get }
                func log(_ message: String)
            }

            struct AnyLogger: Logger {
                let level: Int

                private let _log: (_ message: String) -> Void

                init<T: Logger>(_ base: T) {
                    self.level = base.level

                    self._log = base.log
                }

                func log(_ message: String) {
                    _log(message)
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testMultipleFunctions() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Storage {
                var path: String { get }
                func save(_ data: Data)
                func load() -> Data
                func delete() throws
            }
            """,
            expandedSource:
            """
            protocol Storage {
                var path: String { get }
                func save(_ data: Data)
                func load() -> Data
                func delete() throws
            }

            struct AnyStorage: Storage {
                let path: String

                private let _save: (_ data: Data) -> Void
                private let _load: () -> Data
                private let _delete: () throws -> Void

                init<T: Storage>(_ base: T) {
                    self.path = base.path

                    self._save = base.save
                    self._load = base.load
                    self._delete = base.delete
                }

                func save(_ data: Data) {
                    _save(data)
                }

                func load() -> Data {
                    _load()
                }

                func delete() throws {
                    try _delete()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Property Type Tests

    func testOptionalProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Profile {
                var name: String { get }
                var bio: String? { get }
                var avatar: URL? { get }
            }
            """,
            expandedSource:
            """
            protocol Profile {
                var name: String { get }
                var bio: String? { get }
                var avatar: URL? { get }
            }

            struct AnyProfile: Profile {
                let name: String
                let bio: String?
                let avatar: URL?



                init<T: Profile>(_ base: T) {
                    self.name = base.name
                    self.bio = base.bio
                    self.avatar = base.avatar


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
            @AutoTypeErase
            protocol Container {
                var items: [String] { get }
                var counts: [Int] { get }
            }
            """,
            expandedSource:
            """
            protocol Container {
                var items: [String] { get }
                var counts: [Int] { get }
            }

            struct AnyContainer: Container {
                let items: [String]
                let counts: [Int]



                init<T: Container>(_ base: T) {
                    self.items = base.items
                    self.counts = base.counts


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
            @AutoTypeErase
            protocol Config {
                var settings: [String: Any] { get }
            }
            """,
            expandedSource:
            """
            protocol Config {
                var settings: [String: Any] { get }
            }

            struct AnyConfig: Config {
                let settings: [String: Any]



                init<T: Config>(_ base: T) {
                    self.settings = base.settings


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
            @AutoTypeErase
            protocol Handler {
                var onComplete: () -> Void { get }
            }
            """,
            expandedSource:
            """
            protocol Handler {
                var onComplete: () -> Void { get }
            }

            struct AnyHandler: Handler {
                let onComplete: () -> Void



                init<T: Handler>(_ base: T) {
                    self.onComplete = base.onComplete


                }


            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Error Diagnostics

    func testStructNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            struct User {
                var name: String
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoTypeErase can only be applied to protocols.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testClassNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            class Animal {
                var name: String = ""
            }
            """,
            expandedSource:
            """
            class Animal {
                var name: String = ""
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoTypeErase can only be applied to protocols.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testEnumNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
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
                DiagnosticSpec(message: "@AutoTypeErase can only be applied to protocols.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testActorNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoTypeErase
            actor DataStore {
                var items: [String] = []
            }
            """,
            expandedSource:
            """
            actor DataStore {
                var items: [String] = []
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoTypeErase can only be applied to protocols.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    // MARK: - Edge Cases

    func testEmptyProtocol() throws {
        #if canImport(MacroBreweryMacros)
        // Empty protocol generates no type erasure
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Empty {
            }
            """,
            expandedSource:
            """
            protocol Empty {
            }
            """,
            macros: testMacros
        )
        #endif
    }

    func testProtocolWithOnlyMethods() throws {
        #if canImport(MacroBreweryMacros)
        // Protocol with only methods (no properties) generates no type erasure
        assertMacroExpansion(
            """
            @AutoTypeErase
            protocol Worker {
                func start()
                func stop()
            }
            """,
            expandedSource:
            """
            protocol Worker {
                func start()
                func stop()
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
