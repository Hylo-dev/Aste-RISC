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

let riscvDirectives: [RiscvKeyword] = [
	RiscvKeyword(
		label: ".text",
		category: .directive,
		documentation: "The code section begins",
		instructionDetail: nil,
		directiveDetail: RiscvDirectiveDetail(
			syntax: ".text",
			description: "Indicates the beginning of the executable code section"
		),
		registerDetail: nil
	),
	
	RiscvKeyword(
		label: ".data",
		category: .directive,
		documentation: "The data section begins",
		instructionDetail: nil,
		directiveDetail: RiscvDirectiveDetail(
			syntax: ".data",
			description: "Indicates the beginning of the data section"
		),
		registerDetail: nil
	),
	
	RiscvKeyword(
		label: ".word",
		category: .directive,
		documentation: "Defines a data word.",
		instructionDetail: nil,
		directiveDetail: RiscvDirectiveDetail(
			syntax: ".word [value]",
			description: "Defines a data word with the specified value"
		),
		registerDetail: nil
	),
	
	RiscvKeyword(
		label: ".align",
		category: .directive,
		documentation: "Aligns data to a specified boundary",
		instructionDetail: nil,
		directiveDetail: RiscvDirectiveDetail(
			syntax: ".align [log2(size)]",
			description: "Aligns data to the byte boundary specified by log2(size)"
		),
		registerDetail: nil
	)
]

let riscvRegisters: [RiscvKeyword] = [
	RiscvKeyword(
		label: "x0",
		category: .register,
		documentation: "Register zero",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 0,
			usage: "Always 0. Used for operations that require a zero value."
		)
	),
	
	RiscvKeyword(
		label: "zero",
		category: .register,
		documentation: "Register zero",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 0,
			usage: "Always 0. Used for operations that require a zero value."
		)
	),
	
	RiscvKeyword(
		label: "x1",
		category: .register,
		documentation: "Return address",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 1,
			usage: "Return address for function calls"
		)
	),
	
	RiscvKeyword(
		label: "ra",
		category: .register,
		documentation: "Return address",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 1,
			usage: "Return address for function calls"
		)
	),
	
	RiscvKeyword(
		label: "sp",
		category: .register,
		documentation: "Stack pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 2,
			usage: "Used for local memory management."
		)
	),
	
	RiscvKeyword(
		label: "x3",
		category: .register,
		documentation: "Global pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 3,
			usage: "Used to access global variables"
		)
	),
	
	RiscvKeyword(
		label: "gp",
		category: .register,
		documentation: "Global pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 3,
			usage: "Used to access global variables"
		)
	),
	
	RiscvKeyword(
		label: "x4",
		category: .register,
		documentation: "Thread pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 4,
			usage: "Used for thread management"
		)
	),
	
	RiscvKeyword(
		label: "tp",
		category: .register,
		documentation: "Thread pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 4,
			usage: "Used for thread management"
		)
	),
	
	RiscvKeyword(
		label: "x5",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 5,
			usage: "First temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "t0",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 5,
			usage: "First temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "x6",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 6,
			usage: "First temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "t1",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 6,
			usage: "Second temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "x7",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 7,
			usage: "First temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "t2",
		category: .register,
		documentation: "Temporary register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 7,
			usage: "Third temporary register, used to store data temporarily"
		)
	),
	
	RiscvKeyword(
		label: "x8",
		category: .register,
		documentation: "Saved register | Frame pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 8,
			usage: "First saveable register, used to store data in memory. Also used as a pointer to the top of the frame."
		)
	),
	
	RiscvKeyword(
		label: "s0",
		category: .register,
		documentation: "Saved register | Frame pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 8,
			usage: "First saveable register, used to store data in memory. Also used as a pointer to the top of the frame."
		)
	),
	
	RiscvKeyword(
		label: "fp",
		category: .register,
		documentation: "Saved register | Frame pointer",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 8,
			usage: "First saveable register, used to store data in memory. Also used as a pointer to the top of the frame."
		)
	),
	
	RiscvKeyword(
		label: "x9",
		category: .register,
		documentation: "Saved register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 9,
			usage: "Second saveable register, used to store data in memory"
		)
	),
	
	RiscvKeyword(
		label: "s1",
		category: .register,
		documentation: "Saved register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 9,
			usage: "Second saveable register, used to store data in memory"
		)
	),
	
	RiscvKeyword(
		label: "x10",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 10,
			usage: "First argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "a0",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 10,
			usage: "First argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "x11",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 11,
			usage: "Second argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "a1",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 11,
			usage: "Second argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "x12",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 12,
			usage: "Third argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "a2",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 12,
			usage: "Third argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "x13",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 13,
			usage: "Third argument register, used to pass values to a function and to return the value of a function"
		)
	),
	
	RiscvKeyword(
		label: "a3",
		category: .register,
		documentation: "Argument register",
		instructionDetail: nil,
		directiveDetail: nil,
		registerDetail: RiscvRegisterDetail(
			number: 13,
			usage: "Fourth argument register, used to pass values to a function and to return the value of a function"
		)
	),
]
