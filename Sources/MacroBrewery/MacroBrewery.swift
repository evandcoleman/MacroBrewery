/// Generates a memberwise initializer for structs, classes, and actors.
///
/// The generated initializer includes all stored properties as parameters.
/// Optional properties default to `nil`, and properties with default values preserve them.
///
/// - Parameter accessLevel: The access level for the generated initializer (e.g., "public", "internal").
///                          If nil, inherits from the declaration's access level.
///
/// ## Example
/// ```swift
/// @AutoInit
/// struct User {
///     var name: String
///     var age: Int
///     var email: String?  // defaults to nil
///     var active: Bool = true  // preserves default
/// }
/// // Generates: init(name: String, age: Int, email: String? = nil, active: Bool = true)
/// ```
@attached(member, names: named(init))
public macro AutoInit(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoInitMacro"
)

/// Protocol for types that can be initialized from a raw/DTO type.
///
/// Conforming types must provide an initializer that takes the raw type.
/// Use `@AutoParse` to automatically generate this conformance.
public protocol AutoParseable {
    associatedtype RawType

    init(_ raw: RawType)
}

/// Generates an `AutoParseable` conformance with a parsing initializer.
///
/// Creates an extension that maps properties from a raw/DTO type to the annotated type.
/// Use `@AutoParseable` on properties that should be recursively parsed.
///
/// - Parameters:
///   - raw: The raw/DTO type to parse from.
///   - accessLevel: The access level for the generated initializer.
///
/// ## Example
/// ```swift
/// struct UserDTO {
///     var name: String
///     var age: Int
/// }
///
/// @AutoParse(from: UserDTO.self)
/// struct User {
///     var name: String
///     var age: Int
/// }
/// ```
@attached(extension, conformances: AutoParseable, names: named(init))
public macro AutoParse<T>(
    from raw: T,
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoParseMacro"
)

/// Marks a property for recursive parsing with `@AutoParse`.
///
/// When used on a property within an `@AutoParse` type, the property's value
/// will be initialized using its own `AutoParseable` conformance.
@attached(peer, names: overloaded)
public macro AutoParseable() = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoParseableAttribute"
)

/// Generates a static `stub()` factory method for testing.
///
/// Creates a method that returns an instance with stub values for all properties.
/// Use `@Stub` on properties to specify custom stub values.
///
/// - Parameter accessLevel: The access level for the generated method.
///
/// ## Example
/// ```swift
/// @AutoStub
/// struct User {
///     @Stub("Test User")
///     var name: String
///     @Stub(25)
///     var age: Int
/// }
///
/// let testUser = User.stub()  // name: "Test User", age: 25
/// ```
@attached(member, names: named(stub))
public macro AutoStub(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubMacro"
)

/// Specifies a custom stub value for a property used with `@AutoStub`.
///
/// - Parameter value: The value to use when generating stubs.
@attached(peer, names: overloaded)
public macro Stub<T>(
    _ value: T
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubAttribute"
)

/// Marks a property to use its type's `stub()` method for stub generation.
///
/// Use this when the property's type also conforms to a stubbing pattern.
@attached(peer, names: overloaded)
public macro Stub() = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubAttribute"
)

/// Generates a type-erased wrapper struct for a protocol.
///
/// Creates an `Any<ProtocolName>` struct that wraps any conforming type,
/// similar to `AnyPublisher` or `AnySequence`.
///
/// - Parameter accessLevel: The access level for the generated struct.
///
/// ## Example
/// ```swift
/// @AutoTypeErase
/// protocol Animal {
///     var name: String { get }
///     func speak() async throws
/// }
///
/// // Generates: struct AnyAnimal: Animal { ... }
///
/// let animals: [AnyAnimal] = [AnyAnimal(cat), AnyAnimal(dog)]
/// ```
@attached(peer, names: prefixed(Any))
public macro AutoTypeErase(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoTypeEraseMacro"
)

/// Parameterized testing helper that runs a test for each item in an array.
///
/// Each test case runs in an `XCTContext.runActivity` for clear test reporting.
///
/// - Parameters:
///   - items: The array of test values.
///   - test: The test closure to run for each item.
///
/// ## Example
/// ```swift
/// func testPositiveNumbers() {
///     #testEach([1, 2, 3, 4, 5]) { number in
///         XCTAssertGreaterThan(number, 0)
///     }
/// }
/// ```
@freestanding(expression)
public macro testEach<T>(
    _ items: [T],
    _ test: (T) -> Void
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "TestEachMacro"
)
