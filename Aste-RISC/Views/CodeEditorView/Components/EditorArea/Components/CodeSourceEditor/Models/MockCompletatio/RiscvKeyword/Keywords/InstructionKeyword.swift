//
//  Keywords.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

let riscvInstructions: [RiscvKeyword] = [
	// Type: R
	RiscvKeyword(
		label: "add",
		category: .instruction,
		documentation: "Add two registers",
		instructionDetail: RiscvInstructionDetail(
			type: .R,
			format: "rd, rs1, rs2"
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	RiscvKeyword(
		label: "sub",
		category: .instruction,
		documentation: "Subtract the second register from the first",
		instructionDetail: RiscvInstructionDetail(
			type: .R,
			format: "rd, rs1, rs2"
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	// Type: I
	RiscvKeyword(
		label: "addi",
		category: .instruction,
		documentation: "Add a register with an immediate value",
		instructionDetail: RiscvInstructionDetail(
			type: .I,
			format: "rd, rs1, imm"
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	RiscvKeyword(
		label: "lw",
		category: .instruction,
		documentation: "Load a word from memory",
		instructionDetail: RiscvInstructionDetail(
			type: .I,
			format: "rd, imm(rs1)"),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	// Type: S
	RiscvKeyword(
		label: "sw",
		category: .instruction,
		documentation: "Save a word to memory",
		instructionDetail: RiscvInstructionDetail(
			type: .S,
			format: "rs2, imm(rs1)"
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	// Type: B
	RiscvKeyword(
		label: "beq",
		category: .instruction,
		documentation: "Jump if the two registers are equal",
		instructionDetail: RiscvInstructionDetail(
			type: .B,
			format: "rs1, rs2, label",
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	// Type: U
	RiscvKeyword(
		label: "lui",
		category: .instruction,
		documentation: "Load an immediate value into the upper register",
		instructionDetail: RiscvInstructionDetail(
			type: .U,
			format: "rd, imm"
		),
		directiveDetail: nil,
		registerDetail: nil
	),
	
	// Type: J
	RiscvKeyword(
		label: "jal",
		category: .instruction,
		documentation: "Skip and connect the return address",
		instructionDetail: RiscvInstructionDetail(
			type: .J,
			format: "rd, label"
		),
		directiveDetail: nil,
		registerDetail: nil
	)
]
