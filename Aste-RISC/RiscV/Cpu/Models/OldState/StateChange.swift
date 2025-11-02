//
//  StateChange.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 02/11/25.
//

struct StateChange {
	let oldProgramCounter: UInt32
	let target			 : ChangeTarget
	let oldValue		 : Int 
}
