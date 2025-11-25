//
//  DecodedInstruction.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/10/25.
//

struct DecodedInstruction {
    let operationCode      : UInt8
    let registerSource1    : UInt8
    let registerSource2    : UInt8
    let registerDestination: UInt8
    var immediate          : Int!
    let funz3              : UInt8
    let funz7              : UInt8
	var type			   : TypeInstruction
}
