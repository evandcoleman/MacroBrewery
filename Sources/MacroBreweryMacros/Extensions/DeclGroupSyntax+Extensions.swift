//
//  DeclGroupSyntax+Extensions.swift
//
//
//  Created by Evan Coleman on 9/23/23.
//

import SwiftSyntax

extension DeclGroupSyntax {

    var properties: [VariableDeclSyntax] {
        return memberBlock
            .members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    var functions: [FunctionDeclSyntax] {
        return memberBlock
            .members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }

    var storedProperties: [VariableDeclSyntax] {
        return properties
            .filter(\.isStored)
    }

    var initializers: [InitializerDeclSyntax] {
        return memberBlock
            .members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }

    var associatedTypes: [AssociatedTypeDeclSyntax] {
        return memberBlock
            .members
            .compactMap { $0.decl.as(AssociatedTypeDeclSyntax.self) }
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
}
