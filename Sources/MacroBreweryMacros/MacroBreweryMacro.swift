import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacroBreweryPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AutoBuilderMacro.self,
        AutoInitMacro.self,
        AutoParseableAttribute.self,
        AutoParseMacro.self,
        AutoStubAttribute.self,
        AutoStubMacro.self,
        AutoTypeEraseMacro.self,
    ]
}
