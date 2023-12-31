@attached(member, names: named(init))
public macro AutoInit(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoInitMacro"
)

public protocol AutoParseable {
    associatedtype RawType

    init(_ raw: RawType)
}

@attached(extension, conformances: AutoParseable, names: named(init))
public macro AutoParse<T>(
    from raw: T,
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoParseMacro"
)

@attached(peer, names: overloaded)
public macro AutoParseable() = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoParseableAttribute"
)

@attached(member, names: named(stub))
public macro AutoStub(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubMacro"
)

@attached(peer, names: overloaded)
public macro Stub<T>(
    _ value: T
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubAttribute"
)

@attached(peer, names: overloaded)
public macro Stub() = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubAttribute"
)

@attached(peer, names: prefixed(Any))
public macro AutoTypeErase(
    accessLevel: String? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoTypeEraseMacro"
)

@freestanding(expression)
public macro testEach<T>(
    _ items: [T],
    _ test: (T) -> Void
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "TestEachMacro"
)
