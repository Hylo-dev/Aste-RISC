//
//  RiscvInstructionDetail.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

struct RiscvInstructionDetail {
	let type: RiscvInstructionType
	let format: String // Example: "rd, rs1, rs2" | "rd, imm(rs1)"
}
