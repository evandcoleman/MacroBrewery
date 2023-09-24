//
//  TestEachMacro.swift
//  
//
//  Created by Evan Coleman on 9/23/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct TestEachMacro: ExpressionMacro {

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard
            let eachValues = node.argumentList.first?.expression.as(ArrayExprSyntax.self)?.elements,
            !eachValues.isEmpty
        else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.noValues
                )
            )

            return ""
        }

        guard
            let body = node.argumentList.last?.expression.as(ClosureExprSyntax.self) ?? node.trailingClosure
        else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.noBody
                )
            )

            return ""
        }

        guard
            body.signature?.parameterClause?.firstToken(viewMode: .sourceAccurate) != nil
        else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.noParameter
                )
            )

            return ""
        }

        let cases = eachValues
            .map { element -> ExprSyntax in
                return """
                XCTContext.runActivity(named: String(describing: \(raw: element.expression))) { _ in
                    performTest(\(raw: element.expression))
                }
                """
            }

        return """
        let performTest = { \(body.signature!)
        \(raw: body.statements.map { "\($0.trimmed.with(\.leadingTrivia, node.leadingTrivia).trimmed(matching: \.isNewline))" } .joined(separator: "\n"))
        }
        \(raw: cases.map { "\($0)" } .joined(separator: "\n"))
        """
    }
}

extension TestEachMacro {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case noValues
        case noParameter
        case noBody

        var severity: DiagnosticSeverity {
            switch self {
            case .noParameter, .noBody:
                return .error
            case .noValues:
                return .warning
            }
        }

        var message: String {
            switch self {
            case .noValues:
                return "No values passed to #testEach."
            case .noParameter:
                return "#testEach requires the provided closure to have a single parameter."
            case .noBody:
                return "#testEach requires the second argument be a closure."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

//private extension FunctionDeclSyntax {
//
//    var eachValues: ArrayExprSyntax? {
//        let attribute = attributes.first?.as(AttributeSyntax.self)
//
//        return attribute?.a
//    }
//}
