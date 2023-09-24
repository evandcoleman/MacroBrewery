//
//  AutoStubMacro.swift
//
//
//  Created by Evan Coleman on 9/24/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoStubMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            declaration.supportsAutoStub,
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

        let accessLevel = (attribute.stubAccessLevel ?? declaration.accessLevel)?.appending(" ") ?? ""

        let initSyntax: DeclSyntax = """
        #if DEBUG
        \(raw: accessLevel)static func stub(
        \(raw: makeParameters(for: properties))
        ) -> \(name) {
        \(name)(
        \(
            raw: properties
                .map { "\($0.identifier): \($0.identifier)" }
                .joined(separator: ",\n")
        )
        )
        }
        #endif
        """

        return [initSyntax]
    }

    private static func makeParameters(for properties: [VariableDeclSyntax]) -> String {
        return properties
            .map { property in
                if let stub = property.attribute(named: "Stub"), let value = stub.argumentList?.first {
                    return "\(property.bindings.map { "\($0.with(\.initializer, nil))" } .joined())= \(value.expression)"
                } else if let _ = property.attribute(named: "Stub") {
                    return "\(property.bindings.map { "\($0.with(\.initializer, nil))" } .joined())= .stub()"
                } else if property.isOptional, property.defaultInitializerValue == nil {
                    return "\(property.bindings) = nil"
                } else {
                    return "\(property.bindings)"
                }
            }
            .joined(separator: ",\n")
    }
}

extension AutoStubMacro {
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
                return "@AutoStub can only be applied to classes, structs, and actors."
            case .propertyTypeRequired:
                return "@AutoStub requires that properties provide explicit type information."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

public struct AutoStubAttribute: PeerMacro {

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

extension AutoStubAttribute {
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
                return "@Stub can only be applied to properties."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension DeclGroupSyntax {

    var supportsAutoStub: Bool {
        switch self {
        case is StructDeclSyntax, is ClassDeclSyntax, is ActorDeclSyntax:
            return true
        default:
            return false
        }
    }
}

private extension AttributeSyntax {

    var stubAccessLevel: String? {
        return argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
