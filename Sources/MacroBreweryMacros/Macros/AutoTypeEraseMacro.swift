//
//  AutoTypeEraseMacro.swift
//
//
//  Created by Evan Coleman on 10/3/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AutoTypeEraseMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let proto = declaration.as(ProtocolDeclSyntax.self)
        else {
            context.diagnose(
                .init(
                    node: node._syntaxNode,
                    message: Diagnostic.supportedTypes
                )
            )

            return []
        }

        let properties = proto
            .memberBlock
            .storedProperties
            .filter { $0.type != nil }
        let functions = proto
            .memberBlock
            .functions

        guard !properties.isEmpty else { return [] }

        let accessLevel = (node.autoTypeEraseAccessLevel ?? proto.modifiersProvider.accessLevel)?.appending(" ") ?? ""

        let syntax: DeclSyntax = """
        \(raw: accessLevel)struct Any\(raw: proto.name.trimmed): \(raw: proto.name.trimmed) {
        \(
            raw: properties
                .map { property in
                    return "\(accessLevel)let \(property.identifier): \(property.type!)"
                }
                .joined(separator: "\n")
        )

        \(
            raw: functions
                .map { f in
                    return "private let _\(f.name): (\(f.signature.parameterClause.parameters.map { "_ \($0.secondName ?? $0.firstName): \($0.type)" }.joined(separator: ", ")))\(f.signature.effectSpecifiers?.description ?? "") -> \(f.signature.returnClause?.type ?? "Void")"
                }
                .joined(separator: "\n")
        )

        \(raw: accessLevel)init<T: \(raw: proto.name.trimmed)>(_ base: T) {
        \(
            raw: properties
                .map { "self.\($0.identifier) = base.\($0.identifier)" }
                .joined(separator: "\n")
        )

        \(
            raw: functions
                .map { "self._\($0.name) = base.\($0.name)" }
                .joined(separator: "\n")
        )
        }

        \(
            raw: functions
                .map {
                    var effects: [String] = []
                    if $0.signature.effectSpecifiers?.description.contains("throws") == true {
                        effects.append("try")
                    }
                    if $0.signature.effectSpecifiers?.description.contains("async") == true {
                        effects.append("await")
                    }
                    if !effects.isEmpty {
                        effects.append("")
                    }

                    return """
                    \(accessLevel)func \($0.name)\($0.signature) {
                        \(effects.joined(separator: " "))_\($0.name)(\($0.signature.parameterClause.parameters.map { "\($0.secondName ?? $0.firstName)" } .joined(separator: ", ")))
                    }
                    """
                }
                .joined(separator: "\n\n")
        )
        }
        """

        return [syntax]
    }
}

extension AutoTypeEraseMacro {
    enum Diagnostic: String, Error, DiagnosticMessage {
        case supportedTypes

        var severity: DiagnosticSeverity {
            switch self {
            case .supportedTypes:
                return .error
            }
        }

        var message: String {
            switch self {
            case .supportedTypes:
                return "@AutoTypeErase can only be applied to protocols."
            }
        }

        var diagnosticID: MessageID {
            .init(domain: "MacroBreweryMacros", id: rawValue)
        }
    }
}

private extension AttributeSyntax {

    var autoTypeEraseAccessLevel: String? {
        return argumentList?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
