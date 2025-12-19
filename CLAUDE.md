# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
swift build                    # Build the package
swift test                     # Run all tests
swift run MacroBreweryClient   # Run the example client demonstrating all macros
```

To run a single test:
```bash
swift test --filter MacroBreweryTests.AutoInitMacroTests/testAccessLevelPublic
```

## Architecture

MacroBrewery is a Swift macro package providing compile-time code generation. It uses Swift 5.9's macro system with swift-syntax.

### Target Structure

```
MacroBreweryMacros (Compiler Plugin)
        ↓ depends on
    MacroBrewery (Library - public API)
        ↓ depends on
  MacroBreweryClient (Example executable)
```

- **MacroBreweryMacros**: Core macro implementations using SwiftSyntax. Contains the `@main` CompilerPlugin entry point in `MacroBreweryMacro.swift`.
- **MacroBrewery**: Public `@externalMacro` declarations that consumers import. Also defines `AutoParseable` protocol.
- **MacroBreweryClient**: Working examples in `main.swift` showing all macros in action.

### Macros Provided

| Macro | Type | Purpose |
|-------|------|---------|
| `@AutoInit` | Member | Generates memberwise initializer for struct/class/actor |
| `@AutoStub` | Member | Generates static `stub()` factory for testing |
| `@Stub` | Peer | Marks property with custom stub value |
| `@AutoTypeErase` | Peer | Generates `Any<Protocol>` type-erased wrapper |
| `@AutoParse` | Extension | Generates `AutoParseable` conformance for DTO mapping |
| `@AutoParseable` | Peer | Marks property for nested parsing |

### SwiftSyntax Extensions

Located in `Sources/MacroBreweryMacros/Extensions/`, these provide helper methods for analyzing Swift syntax:
- `DeclGroupSyntax+Extensions`: Declaration name, inherited types, modifiers
- `MemberBlockSyntax+Extensions`: Properties, functions, initializers extraction
- `VariableDeclSyntax+Extensions`: Property analysis (computed, stored, optional, etc.)
- `AttributeSyntax+Extensions`: Macro argument access

### Testing Pattern

Tests use `assertMacroExpansion()` from SwiftSyntaxMacrosTestSupport to verify generated code matches expected output. Each test file registers its macros in a `testMacros` dictionary:

```swift
let testMacros: [String: Macro.Type] = [
    "AutoInit": AutoInitMacro.self,
]
```

## Key Implementation Details

- All macros support optional `accessLevel` parameter (e.g., `"public"`, `"internal"`)
- `@AutoInit` auto-defaults optional properties to `nil` and respects existing default values
- `@AutoTypeErase` only works on protocols; stores function references as closures for erasure
- `@AutoParse` creates extensions adding `AutoParseable` conformance without modifying original types
- Macro implementations provide diagnostic messages for invalid usage via `context.diagnose()`
