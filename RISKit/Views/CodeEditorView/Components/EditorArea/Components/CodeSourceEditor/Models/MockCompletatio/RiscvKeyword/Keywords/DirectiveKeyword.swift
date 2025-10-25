//
//  DirectiveKeyword.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

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
