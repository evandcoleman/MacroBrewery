import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroBreweryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoInitMacro.self,
        AutoStubAttribute.self,
        AutoStubMacro.self,
        TestEachMacro.self,
    ]
}
