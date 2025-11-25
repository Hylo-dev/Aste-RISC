//
//  Returns.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

struct ResultAlu1Bit {
    let result  : Bool
    let carryOut: Bool
	
	init(
		result	: Bool = false,
		carryOut: Bool = false
	) {
		self.result   = result
		self.carryOut = carryOut
	}
}

struct ResultAlu32Bit {
    let result  : Int
    let zero    : Bool
    let overflow: Bool
	
	init(
		result	: Int  = 0,
		zero	: Bool = false,
		overflow: Bool = false
	) {
		self.result   = result
		self.zero 	  = zero
		self.overflow = overflow
	}
}
