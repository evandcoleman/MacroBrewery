//
//  BidirectionalCollection+Extensions.swift
//
//
//  Created by Evan Coleman on 9/24/23.
//

import Foundation

extension BidirectionalCollection {

    func element(at index: Index) -> Element? {
        guard index < endIndex else { return nil }
        return self[index]
    }
}
