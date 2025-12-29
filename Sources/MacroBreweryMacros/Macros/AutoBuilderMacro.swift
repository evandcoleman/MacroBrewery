//
//  AutoBuilderMacro.swift
//
//
//  Created by Evan Coleman on 12/29/24.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoBuilderMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            declaration.supportsAutoBuilder,
            let name = declaration.declarationName
        else {
            context.diagnose(
                .init(
                    node: attribute._syntaxNode,
                    message: Diagnostic.supportedTypes
                )
            )

            return []
        }

        let properties = declaration
            .memberBlock
            .storedProperties
            .filter { property in
                if property.type == nil {
                    context.diagnose(
                        .init(
                            node: property._syntaxNode,
                            message: Diagnostic.propertyTypeRequired
                        )
                    )

                    return false
                }

                return true
            }

        guard !properties.isEmpty else { return [] }

        let accessLevel = (attribute.builderAccessLevel ?? declaration.modifiersProvider.accessLevel)?.appending(" ") ?? ""

        // Generate builder properties
        let builderProperties = properties
            .map { property -> String in
                let type = property.type!.trimmed
                let identifier = property.identifier

                if let defaultValue = property.defaultInitializerValue {
                    return "private var _\(identifier): \(type) = \(defaultValue)"
                } else if property.isOptional {
                    return "private var _\(identifier): \(type) = nil"
                } else {
                    return "private var _\(identifier): \(type)?"
                }
            }
            .joined(separator: "\n")

        // Generate builder setter methods
        let builderSetters = properties
            .map { property -> String in
                let type = property.type!.trimmed
                let identifier = property.identifier

                return """
                @discardableResult
                \(accessLevel)func \(identifier)(_ \(identifier): \(type)) -> Builder {
                self._\(identifier) = \(identifier)
                return self
                }
                """
            }
            .joined(separator: "\n\n")

        // Generate build method
        let buildAssignments = properties
            .map { property -> String in
                let identifier = property.identifier
                let hasDefault = property.defaultInitializerValue != nil || property.isOptional

                if hasDefault {
                    return "\(identifier): _\(identifier)"
                } else {
                    return "\(identifier): _\(identifier)!"
                }
            }
            .joined(separator: ",\n")

        let builderClass: DeclSyntax = """
        \(raw: accessLevel)class Builder {
        \(raw: builderProperties)

        \(raw: accessLevel)init() {}

        \(raw: builderSetters)

        \(raw: accessLevel)func build() -> \(name) {
        \(name)(
        \(raw: buildAssignments)
        )
        }
        }
        """

        let builderMethod: DeclSyntax = """
        \(raw: accessLevel)static func builder() -> Builder {
        Builder()
        }
        """

        return [builderClass, builderMethod]
    }
}

extension AutoBuilderMacro {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case supportedTypes
        case propertyTypeRequired

        var severity: DiagnosticSeverity {
            switch self {
            case .supportedTypes, .propertyTypeRequired:
                return .error
            }
        }

        var message: String {
            switch self {
            case .supportedTypes:
                return "@AutoBuilder can only be applied to structs."
            case .propertyTypeRequired:
                return "@AutoBuilder requires that properties provide explicit type information."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension DeclGroupSyntax {

    var supportsAutoBuilder: Bool {
        switch self {
        case is StructDeclSyntax:
            return true
        default:
            return false
        }
    }
}

private extension AttributeSyntax {

    var builderAccessLevel: String? {
        return argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
