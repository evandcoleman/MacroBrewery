//
//  main.swift
//
//
//  Created by Evan Coleman on 9/24/23.
//

import Foundation
import MacroBrewery

@AutoTypeErase
public protocol Animal {
    var age: Int { get }
    var name: String? { get }
    var soft: Bool { get }

    func pet() async throws
    func feed(_ completion: @escaping () -> Void) -> Any
}

@AutoInit
@AutoStub
public struct Household {

    @Stub([])
    public var animals: [Cat]

    init() {
        animals = []
    }
}

@AutoInit
@AutoStub
public struct Cat {

    @Stub(7)
    public var age: Int
    @Stub("Luna")
    public var name: String?
    @Stub(false)
    public var soft: Bool

    public var fuzzy: Bool = true
    @Stub(true)
    public var small: Bool = false

    init() {
        age = 0
        soft = false
    }
}

let myHome = Household(
    animals: [
        Cat(
            age: 7,
            name: "Leo",
            soft: true
        ),
        Cat(
            age: 7,
            name: "Luna",
            soft: false,
            small: true
        ),
    ]
)

#if DEBUG
let stubbedHousehold = Household.stub()
let stubbedCat = Cat.stub()
#endif
