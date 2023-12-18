//
//  AutoParseMacro.swift
//  
//
//  Created by Evan Coleman on 9/24/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoParseMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if !declaration.supportsAutoParse {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.supportedTypes
                )
            )

            return []
        }

        guard let rawType = node.rawType else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.noRawType
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

        let accessLevel = (node.accessLevel ?? declaration.modifiersProvider.accessLevel)?.appending(" ") ?? ""

        let syntax: ExtensionDeclSyntax = try ExtensionDeclSyntax("""
        extension \(type): AutoParseable {
        \(raw: accessLevel)init(_ raw: \(raw: rawType)) {
        self.init(
        \(
            raw: properties
                .map { "\($0.identifier): \(makeParseIdentifier(property: $0))" }
                .joined(separator: ",\n")
        )
        )
        }
        }
        """)

        return [syntax]
    }

    private static func makeParseIdentifier(property: VariableDeclSyntax) -> String {
        if property.attribute(named: "AutoParseable") != nil {
            return "raw.\(property.identifier).map { .init($0) }"
        } else {
            return "raw.\(property.identifier)"
        }
    }
}

extension AutoParseMacro {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case supportedTypes
        case propertyTypeRequired
        case noRawType

        var severity: DiagnosticSeverity {
            switch self {
            case .supportedTypes, .noRawType, .propertyTypeRequired:
                return .error
            }
        }

        var message: String {
            switch self {
            case .supportedTypes:
                return "@AutoParse can only be applied to classes, structs, and actors."
            case .noRawType:
                return "@AutoParse requires an argument with the type to parse from."
            case .propertyTypeRequired:
                return "@AutoParse requires that properties provide explicit type information."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

public struct AutoParseableAttribute: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(VariableDeclSyntax.self) else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.notProperty
                )
            )

            return []
        }

        return []
    }
}

extension AutoParseableAttribute {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case notProperty

        var severity: DiagnosticSeverity {
            switch self {
            case .notProperty:
                return .error
            }
        }

        var message: String {
            switch self {
            case .notProperty:
                return "@AutoParseable can only be applied to properties."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension DeclGroupSyntax {

    var supportsAutoParse: Bool {
        switch self {
        case is StructDeclSyntax, is ClassDeclSyntax, is ActorDeclSyntax:
            return true
        default:
            return false
        }
    }
}

private extension AttributeSyntax {

    var rawType: TokenSyntax? {
        guard
            let expression = argumentList?.first?.expression.as(MemberAccessExprSyntax.self),
            let argument = expression.base?.as(DeclReferenceExprSyntax.self)?.baseName
        else {
            return nil
        }

        return argument
    }

    var accessLevel: String? {
        guard
            let argumentList,
            argumentList.count > 1,
            let argument = argumentList.element(at: argumentList.index(before: argumentList.endIndex))
        else {
            return nil
        }

        return argument
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
