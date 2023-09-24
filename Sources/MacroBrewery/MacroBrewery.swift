import MacroBreweryMacros

@attached(member, names: named(init))
public macro AutoInit(
    accessLevel: AutoInitMacro.AccessLevel? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoInitMacro"
)

@attached(member, names: named(stub))
public macro AutoStub(
    accessLevel: AutoStubMacro.AccessLevel? = nil
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "AutoStubMacro"
)

@attached(memberAttribute)
public macro Stub<T>(
    _ value: T
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "StubAttribute"
)

@freestanding(expression)
public macro testEach<T>(
    _ items: [T],
    _ test: (T) -> Void
) = #externalMacro(
    module: "MacroBreweryMacros",
    type: "TestEachMacro"
)
