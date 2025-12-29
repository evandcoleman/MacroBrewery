//
//  EnumPropertiesMacro.swift
//
//
//  Created by Evan Coleman on 12/29/24.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EnumPropertiesMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(
                .init(
                    node: attribute._syntaxNode,
                    message: Diagnostic.enumOnly
                )
            )

            return []
        }

        let accessLevel = (attribute.enumPropertiesAccessLevel ?? declaration.modifiersProvider.accessLevel)?.appending(" ") ?? ""

        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap { $0.elements }

        guard !cases.isEmpty else { return [] }

        var results: [DeclSyntax] = []

        for enumCase in cases {
            let caseName = enumCase.name.text
            let capitalizedName = caseName.prefix(1).uppercased() + caseName.dropFirst()

            // Generate is{CaseName} computed property
            let isCaseProperty: DeclSyntax = """
            \(raw: accessLevel)var is\(raw: capitalizedName): Bool {
            if case .\(raw: caseName) = self { return true }
            return false
            }
            """
            results.append(isCaseProperty)

            // Generate associated value accessor if the case has associated values
            if let associatedValue = enumCase.parameterClause {
                let parameters = associatedValue.parameters

                if parameters.count == 1, let param = parameters.first {
                    // Single associated value - return the value directly
                    let paramType = param.type
                    let paramName = param.firstName?.text ?? "value"

                    let valueProperty: DeclSyntax = """
                    \(raw: accessLevel)var \(raw: caseName): \(paramType)? {
                    if case .\(raw: caseName)(let \(raw: paramName)) = self { return \(raw: paramName) }
                    return nil
                    }
                    """
                    results.append(valueProperty)
                } else if parameters.count > 1 {
                    // Multiple associated values - return a tuple
                    let tupleTypes = parameters
                        .map { param -> String in
                            if let label = param.firstName?.text, label != "_" {
                                return "\(label): \(param.type)"
                            } else {
                                return "\(param.type)"
                            }
                        }
                        .joined(separator: ", ")

                    let letBindings = parameters
                        .enumerated()
                        .map { index, param -> String in
                            let name = param.firstName?.text ?? "v\(index)"
                            if name == "_" {
                                return "let v\(index)"
                            }
                            return "let \(name)"
                        }
                        .joined(separator: ", ")

                    let returnValues = parameters
                        .enumerated()
                        .map { index, param -> String in
                            let name = param.firstName?.text ?? "v\(index)"
                            if name == "_" {
                                return "v\(index)"
                            }
                            return name
                        }
                        .joined(separator: ", ")

                    let valueProperty: DeclSyntax = """
                    \(raw: accessLevel)var \(raw: caseName): (\(raw: tupleTypes))? {
                    if case .\(raw: caseName)(\(raw: letBindings)) = self { return (\(raw: returnValues)) }
                    return nil
                    }
                    """
                    results.append(valueProperty)
                }
            }
        }

        return results
    }
}

extension EnumPropertiesMacro {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case enumOnly

        var severity: DiagnosticSeverity {
            switch self {
            case .enumOnly:
                return .error
            }
        }

        var message: String {
            switch self {
            case .enumOnly:
                return "@EnumProperties can only be applied to enums."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension AttributeSyntax {

    var enumPropertiesAccessLevel: String? {
        return argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
