//
//  AutoInitMacro.swift
//  
//
//  Created by Evan Coleman on 9/23/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoInitMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if !declaration.supportsAutoInit {
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

        let accessLevel = (attribute.initAccessLevel ?? declaration.modifiersProvider.accessLevel)?.appending(" ") ?? ""

        let initSyntax: DeclSyntax = """
        \(raw: accessLevel)init(
        \(raw: makeParameters(for: properties))
        ) {
        \(
            raw: properties
                .map { "self.\($0.identifier) = \($0.identifier)" }
                .joined(separator: "\n")
        )
        }
        """

        return [initSyntax]
    }

    private static func makeParameters(for properties: [VariableDeclSyntax]) -> String {
        return properties
            .map { property in
                if property.isOptional, property.defaultInitializerValue == nil {
                    return "\(property.bindings) = nil"
                } else {
                    return "\(property.bindings)"
                }
            }
            .joined(separator: ",\n")
    }
}

extension AutoInitMacro {
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
                return "@AutoInit can only be applied to classes, structs, and actors."
            case .propertyTypeRequired:
                return "@AutoInit requires that properties provide explicit type information."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension DeclGroupSyntax {

    var supportsAutoInit: Bool {
        switch self {
        case is StructDeclSyntax, is ClassDeclSyntax, is ActorDeclSyntax:
            return true
        default:
            return false
        }
    }
}

private extension AttributeSyntax {

    var initAccessLevel: String? {
        return argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
