# MacroBrewery

[![CI](https://github.com/evandcoleman/MacroBrewery/actions/workflows/ci.yml/badge.svg)](https://github.com/evandcoleman/MacroBrewery/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/evandcoleman/MacroBrewery/graph/badge.svg)](https://codecov.io/gh/evandcoleman/MacroBrewery)

A collection of useful Swift macros for code generation.

## Requirements

- Swift 5.9+
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6+

## Installation

Add MacroBrewery to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/evandcoleman/MacroBrewery.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["MacroBrewery"]
)
```

## Macros

### @AutoInit

Generates a memberwise initializer for structs, classes, and actors.

```swift
@AutoInit
struct User {
    var name: String
    var age: Int
    var email: String? // Defaults to nil
    var isActive: Bool = true // Preserves default value
}

// Generated:
// init(name: String, age: Int, email: String? = nil, isActive: Bool = true)
```

### @AutoStub

Generates a static `stub()` factory method for testing. Use `@Stub` to specify custom values.

```swift
@AutoStub
struct User {
    @Stub("John Doe")
    var name: String
    @Stub(25)
    var age: Int
    var email: String? // Defaults to nil
}

// Usage:
let testUser = User.stub()
// testUser.name == "John Doe"
// testUser.age == 25
```

### @AutoTypeErase

Generates a type-erased wrapper for protocols (like `AnyPublisher`).

```swift
@AutoTypeErase
protocol Animal {
    var name: String { get }
    func speak() async throws
}

// Generated: struct AnyAnimal: Animal { ... }

// Usage:
let animals: [AnyAnimal] = [
    AnyAnimal(cat),
    AnyAnimal(dog)
]
```

### @AutoParse

Generates parsing initializers for converting from DTO/raw types.

```swift
struct UserDTO {
    var name: String
    var age: Int
}

@AutoParse(from: UserDTO.self)
struct User {
    var name: String
    var age: Int
}

// Generated:
// extension User: AutoParseable {
//     init(_ raw: UserDTO) { ... }
// }
```

### @AutoBuilder

Generates a Builder pattern for struct construction with fluent API.

```swift
@AutoBuilder
struct NetworkRequest {
    var url: URL
    var method: String = "GET"
    var timeout: TimeInterval = 30
}

// Usage:
let request = NetworkRequest.builder()
    .url(myURL)
    .method("POST")
    .timeout(60)
    .build()
```

### @EnumProperties

Generates computed properties for enum case checking and associated value extraction.

```swift
@EnumProperties
enum LoadingState {
    case idle
    case loading(progress: Double)
    case success(data: Data)
    case failure(error: Error)
}

// Generated properties:
let state = LoadingState.loading(progress: 0.5)
state.isLoading  // true
state.loading    // Optional(0.5)
state.isSuccess  // false
state.success    // nil
```

## Access Levels

All macros support an optional `accessLevel` parameter:

```swift
@AutoInit(accessLevel: "public")
public struct PublicUser {
    public var name: String
}
```

## License

MIT License. See [LICENSE](LICENSE) for details.
