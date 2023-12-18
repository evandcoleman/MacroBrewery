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
            .contains { $0.accessorBlock?.as(AccessorBlockSyntax.self)?.accessors.as(CodeBlockItemListSyntax.self)?.isEmpty == false }
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

    var bindingsForInitializer: PatternBindingListSyntax {
        return PatternBindingListSyntax(
            bindings
                .map { binding in
                    var newBinding = binding
                    newBinding.accessorBlock = nil
                    return newBinding
                }
        )
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
