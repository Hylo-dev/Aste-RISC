//
//  NumberBaseReg.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

enum NumberBaseReg: String, Identifiable, CaseIterable {
	case dec = "dec"
	case bin = "bin"
	case hex = "hex"
	case oct = "oct"
	
	var base: Int {
		switch self {
			case .dec: 10
			case .bin: 2
			case .hex: 16
			case .oct: 8
		}
	}
	
	var id: String { rawValue }
}
