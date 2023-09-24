//
//  VariableDeclSyntax+Extensions.swift
//
//
//  Created by Evan Coleman on 9/23/23.
//

import SwiftSyntax

extension VariableDeclSyntax {

    var isComputed: Bool {
        return bindings
            .contains { $0.accessorBlock?.is(CodeBlockSyntax.self) == true }
    }

    var isStored: Bool {
        return !isComputed
    }

    var isStatic: Bool {
        return modifiers.lazy
            .contains { $0.name.tokenKind == .keyword(.static) }
    }

    var isOptional: Bool {
        type?.is(OptionalTypeSyntax.self) ?? false
    }

    var identifier: TokenSyntax {
        return bindings.lazy
            .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
            .first!.identifier
    }

    var type: TypeSyntax? {
        return bindings.lazy.compactMap(\.typeAnnotation).first?.type
    }

    var defaultInitializerValue: ExprSyntax? {
        return bindings.lazy.compactMap(\.initializer).first?.value
    }

    func attribute(named name: String) -> AttributeSyntax? {
        return attributes
            .first { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name }?
            .as(AttributeSyntax.self)
    }
}
