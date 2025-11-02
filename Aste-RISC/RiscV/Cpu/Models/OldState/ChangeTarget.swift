//
//  ChangeTarget.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 02/11/25.
//

enum ChangeTarget {
	case register(index: Int)
	case memory(address: UInt32)
	case none
}
