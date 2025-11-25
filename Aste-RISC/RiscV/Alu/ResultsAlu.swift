//
//  Returns.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

struct ResultAlu1Bit {
    let result  : Bool
    let carryOut: Bool
}

struct ResultAlu32Bit {
    let result  : Int  = 0
    let zero    : Bool = false
    let overflow: Bool = false
}
