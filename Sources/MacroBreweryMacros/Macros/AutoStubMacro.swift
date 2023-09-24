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

    public enum AccessLevel: CaseIterable {
        case `public`
        case `internal`
        case `private`
        case `fileprivate`
    }

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

        let accessLevelExpression = attribute.argumentList?
            .first?.expression
            .as(MemberAccessExprSyntax.self)
        let accessLevel = accessLevelExpression?.declName.baseName.text.appending(" ") ?? ""

        let initSyntax: DeclSyntax = """
        \(raw: accessLevel)static func stub(
        \(raw: makeParameters(for: properties))
        ) -> \(name) {
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
                if let stub = property.attribute(named: "Stub"), let value = stub.argumentList?.first {
                    return "\(property.bindings.map { "\($0.with(\.initializer, nil))" } .joined())= \(value.expression)"
                } else if property.isOptional, property.defaultInitializerValue == nil {
                    return "\(property.bindings) = nil"
                } else {
                    return "\(property.bindings)"
                }
            }
            .joined(separator: ",\n")
    }
}

public struct StubAttribute: MemberAttributeMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        return []
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
