//
//  DeclGroupSyntax+Extensions.swift
//
//
//  Created by Evan Coleman on 9/23/23.
//

import SwiftSyntax

extension DeclGroupSyntax {

    var inheritedTypes: [TypeSyntax] {
        return inheritanceClause?.inheritedTypes.map(\.type) ?? []
    }

    var declarationName: TokenSyntax? {
        if let declaration = self.as(ClassDeclSyntax.self) {
            return declaration.name.trimmed
        } else if let declaration = self.as(StructDeclSyntax.self) {
            return declaration.name.trimmed
        } else if let declaration = self.as(ActorDeclSyntax.self) {
            return declaration.name.trimmed
        }

        return nil
    }

    var modifiersProvider: DeclModifiersProvider {
        DeclModifiersProvider(modifiers: modifiers)
    }
}

extension MemberBlockSyntax {
    var properties: [VariableDeclSyntax] {
        return members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    var functions: [FunctionDeclSyntax] {
        return members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }

    var storedProperties: [VariableDeclSyntax] {
        return properties
            .filter(\.isStored)
            .filter { !$0.isStatic }
            .filter(\.hasIdentifierPattern)
    }

    var initializers: [InitializerDeclSyntax] {
        return members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }

    var associatedTypes: [AssociatedTypeDeclSyntax] {
        return members
            .compactMap { $0.decl.as(AssociatedTypeDeclSyntax.self) }
    }
}

extension ProtocolDeclSyntax {

    var modifiersProvider: DeclModifiersProvider {
        DeclModifiersProvider(modifiers: modifiers)
    }
}

struct DeclModifiersProvider {
    var modifiers: DeclModifierListSyntax

    var accessLevel: String? {
        return modifiers
            .compactMap { $0.as(DeclModifierSyntax.self)?.name.tokenKind }
            .compactMap { token -> String? in
                switch token {
                case .keyword(let keyword):
                    switch keyword {
                    case .public:
                        return "public"
                    case .private:
                        return "private"
                    case .internal:
                        return "internal"
                    case .fileprivate:
                        return "fileprivate"
                    default:
                        return nil
                    }
                default:
                    return nil
                }
            }
            .first
    }
}
