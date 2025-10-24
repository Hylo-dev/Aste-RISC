//
//  AssemblerBridge.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/10/25.
//

import Foundation

/// This class execute assembler, manage errors and warnings on terminal
class AssemblerBridge {
	static let shared = AssemblerBridge()
	@MainActor var terminal = TerminalOutputModel()
	
	func assemble(optionsAsembler: UnsafeMutablePointer<options_t>) -> Int {
		return Int(parse_riscv_file(optionsAsembler, AssemblerBridge.cCallback))
	}
	
	static let cCallback: @convention(c) (assembler_message_t) -> Void = { message in				
		Task { @MainActor in AssemblerBridge.shared.terminal.append(message) }
	}
}
