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
    public var animals: [AnyAnimal]

    init() {
        animals = []
    }
}

@AutoInit
@AutoStub
public struct Cat: Animal {

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

    public func pet() async throws {

    }

    public func feed(_ completion: @escaping () -> Void) -> Any {
        return ""
    }
}

let myHome = Household(
    animals: [
        AnyAnimal(Cat(
            age: 7,
            name: "Leo",
            soft: true
        )),
        AnyAnimal(Cat(
            age: 7,
            name: "Luna",
            soft: false,
            small: true
        )),
    ]
)

let stubbedHousehold = Household.stub()
let stubbedCat = Cat.stub()
