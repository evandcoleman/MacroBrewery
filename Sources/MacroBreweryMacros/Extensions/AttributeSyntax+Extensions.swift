//
//  AttributeSyntax+Extensions.swift
//
//
//  Created by Evan Coleman on 9/23/23.
//

import SwiftSyntax

extension AttributeSyntax {

    var argumentList: LabeledExprListSyntax? {
        switch arguments {
        case .some(.argumentList(let value)):
            return value
        default:
            return nil
        }
    }
}
