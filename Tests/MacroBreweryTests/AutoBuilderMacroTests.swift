import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacroBreweryMacros)
import MacroBreweryMacros
#endif

final class AutoBuilderMacroTests: XCTestCase {

    #if canImport(MacroBreweryMacros)
    let testMacros: [String: Macro.Type] = [
        "AutoBuilder": AutoBuilderMacro.self,
    ]
    #endif

    // MARK: - Basic Builder Tests

    func testBasicStruct() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            struct NetworkRequest {
                var url: URL
                var method: String = "GET"
                var timeout: TimeInterval = 30
            }
            """,
            expandedSource:
            """
            struct NetworkRequest {
                var url: URL
                var method: String = "GET"
                var timeout: TimeInterval = 30

                class Builder {
                    private var _url: URL?
                    private var _method: String = "GET"
                    private var _timeout: TimeInterval = 30

                    init() {
                    }

                    @discardableResult
                    func url(_ url: URL) -> Builder {
                        self._url = url
                        return self
                    }

                    @discardableResult
                    func method(_ method: String) -> Builder {
                        self._method = method
                        return self
                    }

                    @discardableResult
                    func timeout(_ timeout: TimeInterval) -> Builder {
                        self._timeout = timeout
                        return self
                    }

                    func build() -> NetworkRequest {
                        NetworkRequest(
                            url: _url!,
                            method: _method,
                            timeout: _timeout
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
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
            @AutoBuilder(accessLevel: "public")
            struct Config {
                var name: String
            }
            """,
            expandedSource:
            """
            struct Config {
                var name: String

                public class Builder {
                    private var _name: String?

                    public init() {
                    }

                    @discardableResult
                    public func name(_ name: String) -> Builder {
                        self._name = name
                        return self
                    }

                    public func build() -> Config {
                        Config(
                            name: _name!
                        )
                    }
                }

                public static func builder() -> Builder {
                    Builder()
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
            @AutoBuilder(accessLevel: "internal")
            struct Settings {
                var enabled: Bool = false
            }
            """,
            expandedSource:
            """
            struct Settings {
                var enabled: Bool = false

                internal class Builder {
                    private var _enabled: Bool = false

                    internal init() {
                    }

                    @discardableResult
                    internal func enabled(_ enabled: Bool) -> Builder {
                        self._enabled = enabled
                        return self
                    }

                    internal func build() -> Settings {
                        Settings(
                            enabled: _enabled
                        )
                    }
                }

                internal static func builder() -> Builder {
                    Builder()
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
            @AutoBuilder(accessLevel: "private")
            struct Internal {
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Internal {
                var value: Int

                private class Builder {
                    private var _value: Int?

                    private init() {
                    }

                    @discardableResult
                    private func value(_ value: Int) -> Builder {
                        self._value = value
                        return self
                    }

                    private func build() -> Internal {
                        Internal(
                            value: _value!
                        )
                    }
                }

                private static func builder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Optional Properties Tests

    func testOptionalProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            struct User {
                var name: String
                var email: String?
                var phone: String?
            }
            """,
            expandedSource:
            """
            struct User {
                var name: String
                var email: String?
                var phone: String?

                class Builder {
                    private var _name: String?
                    private var _email: String? = nil
                    private var _phone: String? = nil

                    init() {
                    }

                    @discardableResult
                    func name(_ name: String) -> Builder {
                        self._name = name
                        return self
                    }

                    @discardableResult
                    func email(_ email: String?) -> Builder {
                        self._email = email
                        return self
                    }

                    @discardableResult
                    func phone(_ phone: String?) -> Builder {
                        self._phone = phone
                        return self
                    }

                    func build() -> User {
                        User(
                            name: _name!,
                            email: _email,
                            phone: _phone
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Complex Types Tests

    func testArrayProperties() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            struct Container {
                var items: [String] = []
                var counts: [Int]
            }
            """,
            expandedSource:
            """
            struct Container {
                var items: [String] = []
                var counts: [Int]

                class Builder {
                    private var _items: [String] = []
                    private var _counts: [Int]?

                    init() {
                    }

                    @discardableResult
                    func items(_ items: [String]) -> Builder {
                        self._items = items
                        return self
                    }

                    @discardableResult
                    func counts(_ counts: [Int]) -> Builder {
                        self._counts = counts
                        return self
                    }

                    func build() -> Container {
                        Container(
                            items: _items,
                            counts: _counts!
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
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
            @AutoBuilder
            struct Headers {
                var values: [String: String] = [:]
            }
            """,
            expandedSource:
            """
            struct Headers {
                var values: [String: String] = [:]

                class Builder {
                    private var _values: [String: String] = [:]

                    init() {
                    }

                    @discardableResult
                    func values(_ values: [String: String]) -> Builder {
                        self._values = values
                        return self
                    }

                    func build() -> Headers {
                        Headers(
                            values: _values
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
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
        assertMacroExpansion(
            """
            @AutoBuilder
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

    func testSingleProperty() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            struct Wrapper {
                var value: Int
            }
            """,
            expandedSource:
            """
            struct Wrapper {
                var value: Int

                class Builder {
                    private var _value: Int?

                    init() {
                    }

                    @discardableResult
                    func value(_ value: Int) -> Builder {
                        self._value = value
                        return self
                    }

                    func build() -> Wrapper {
                        Wrapper(
                            value: _value!
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
                }
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
            @AutoBuilder
            struct WithStatic {
                static var defaultValue: Int = 0
                var name: String
            }
            """,
            expandedSource:
            """
            struct WithStatic {
                static var defaultValue: Int = 0
                var name: String

                class Builder {
                    private var _name: String?

                    init() {
                    }

                    @discardableResult
                    func name(_ name: String) -> Builder {
                        self._name = name
                        return self
                    }

                    func build() -> WithStatic {
                        WithStatic(
                            name: _name!
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
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
            @AutoBuilder
            struct Rectangle {
                var width: Double
                var height: Double
                var area: Double {
                    width * height
                }
            }
            """,
            expandedSource:
            """
            struct Rectangle {
                var width: Double
                var height: Double
                var area: Double {
                    width * height
                }

                class Builder {
                    private var _width: Double?
                    private var _height: Double?

                    init() {
                    }

                    @discardableResult
                    func width(_ width: Double) -> Builder {
                        self._width = width
                        return self
                    }

                    @discardableResult
                    func height(_ height: Double) -> Builder {
                        self._height = height
                        return self
                    }

                    func build() -> Rectangle {
                        Rectangle(
                            width: _width!,
                            height: _height!
                        )
                    }
                }

                static func builder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Error Diagnostics

    func testClassNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            class User {
                var name: String
            }
            """,
            expandedSource:
            """
            class User {
                var name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoBuilder can only be applied to structs.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testEnumNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
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
                DiagnosticSpec(message: "@AutoBuilder can only be applied to structs.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testActorNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            actor DataStore {
                var items: [String]
            }
            """,
            expandedSource:
            """
            actor DataStore {
                var items: [String]
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoBuilder can only be applied to structs.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testProtocolNotSupported() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            protocol Buildable {
                var name: String { get }
            }
            """,
            expandedSource:
            """
            protocol Buildable {
                var name: String { get }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoBuilder can only be applied to structs.", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #endif
    }

    func testPropertyWithoutType() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            struct Config {
                var name = "default"
            }
            """,
            expandedSource:
            """
            struct Config {
                var name = "default"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@AutoBuilder requires that properties provide explicit type information.", line: 3, column: 5)
            ],
            macros: testMacros
        )
        #endif
    }

    // MARK: - Access Level Inheritance

    func testAccessLevelInheritsFromDeclaration() throws {
        #if canImport(MacroBreweryMacros)
        assertMacroExpansion(
            """
            @AutoBuilder
            public struct PublicConfig {
                public var name: String
            }
            """,
            expandedSource:
            """
            public struct PublicConfig {
                public var name: String

                public class Builder {
                    private var _name: String?

                    public init() {
                    }

                    @discardableResult
                    public func name(_ name: String) -> Builder {
                        self._name = name
                        return self
                    }

                    public func build() -> PublicConfig {
                        PublicConfig(
                            name: _name!
                        )
                    }
                }

                public static func builder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
