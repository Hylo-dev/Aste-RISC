//
//  CallFrame.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import Foundation
struct CallFrame: Identifiable {
	let id 				  : UUID = UUID()
	let startAddress 	  : UInt32
	let size			  : UInt32
	let returnAddress	  : UInt32?
	let savedFP			  : UInt32?
	let words			  : [StackFrame]
	
	var functionName: String {
		if let ra = returnAddress { return "Frame @ 0x\(String(format: "%x", ra))" }
		return "Frame"
	}
}
