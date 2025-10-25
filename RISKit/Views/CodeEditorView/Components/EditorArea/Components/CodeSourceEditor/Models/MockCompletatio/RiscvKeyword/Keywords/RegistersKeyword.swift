//
//  RegistersKeyword.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

let riscvRegisters: [RiscvKeyword] = {
	var regs: [RiscvKeyword] = [
		// Zero register
		RiscvKeyword(
			label: "x0",
			category: .register,
			documentation: "Zero register",
			instructionDetail: nil,
			directiveDetail: nil,
			registerDetail: RiscvRegisterDetail(
				number: 0,
				usage: "Always 0. Used for operations requiring a constant zero value."
			)
		),
		RiscvKeyword(
			label: "zero",
			category: .register,
			documentation: "Zero register",
			instructionDetail: nil,
			directiveDetail: nil,
			registerDetail: RiscvRegisterDetail(
				number: 0,
				usage: "Always 0. Used for operations requiring a constant zero value."
			)
		),
		
		// Return address
		RiscvKeyword(
			label: "x1",
			category: .register,
			documentation: "Return address",
			instructionDetail: nil,
			directiveDetail: nil,
			registerDetail: RiscvRegisterDetail(
				number: 1,
				usage: "Holds the return address for function calls."
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
				usage: "Holds the return address for function calls."
			)
		),
		
		// Stack and global/thread pointers
		RiscvKeyword(
			label: "x2",
			category: .register,
			documentation: "Stack pointer",
			instructionDetail: nil,
			directiveDetail: nil,
			registerDetail: RiscvRegisterDetail(
				number: 2,
				usage: "Points to the top of the current stack frame."
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
				usage: "Points to the top of the current stack frame."
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
				usage: "Used to access global variables."
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
				usage: "Used to access global variables."
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
				usage: "Used for thread-local storage."
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
				usage: "Used for thread-local storage."
			)
		),
		
		// Temporaries
		RiscvKeyword(label: "x5", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 5, usage: "Temporary register t0.")),
		RiscvKeyword(label: "t0", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 5, usage: "Temporary register t0.")),
		RiscvKeyword(label: "x6", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 6, usage: "Temporary register t1.")),
		RiscvKeyword(label: "t1", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 6, usage: "Temporary register t1.")),
		RiscvKeyword(label: "x7", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 7, usage: "Temporary register t2.")),
		RiscvKeyword(label: "t2", category: .register, documentation: "Temporary register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 7, usage: "Temporary register t2.")),
		
		// Saved registers / Frame pointer
		RiscvKeyword(label: "x8", category: .register, documentation: "Saved register / Frame pointer", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 8, usage: "Saved register s0 or frame pointer (fp).")),
		RiscvKeyword(label: "s0", category: .register, documentation: "Saved register / Frame pointer", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 8, usage: "Saved register s0 or frame pointer (fp).")),
		RiscvKeyword(label: "fp", category: .register, documentation: "Frame pointer", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 8, usage: "Frame pointer used for stack frame references.")),
		RiscvKeyword(label: "x9", category: .register, documentation: "Saved register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 9, usage: "Saved register s1.")),
		RiscvKeyword(label: "s1", category: .register, documentation: "Saved register", instructionDetail: nil, directiveDetail: nil, registerDetail: RiscvRegisterDetail(number: 9, usage: "Saved register s1."))
	]
	
	// Argument registers (a0–a7)
	for i in 10...17 {
		let name = "a\(i - 10)"
		regs.append(contentsOf: [
			RiscvKeyword(
				label: "x\(i)",
				category: .register,
				documentation: "Argument register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: name == "a0" ?
					"Argument register \(name). Used to pass or return function values." :
					"Argument register \(name). Used to pass function values."
				)
			),
			RiscvKeyword(
				label: name,
				category: .register,
				documentation: "Argument register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: name == "a0" ?
					"Argument register \(name). Used to pass or return function values." :
					"Argument register \(name). Used to pass function values."
				)
			)
		])
	}
	
	// Saved registers (s2–s11)
	for i in 18...27 {
		let name = "s\(i - 16)"
		regs.append(contentsOf: [
			RiscvKeyword(
				label: "x\(i)",
				category: .register,
				documentation: "Saved register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: "Saved register \(name). Used to preserve values across function calls."
				)
			),
			RiscvKeyword(
				label: name,
				category: .register,
				documentation: "Saved register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: "Saved register \(name). Used to preserve values across function calls."
				)
			)
		])
	}
	
	// Additional temporaries (t3–t6)
	for i in 28...31 {
		let name = "t\(i - 25)"
		regs.append(contentsOf: [
			RiscvKeyword(
				label: "x\(i)",
				category: .register,
				documentation: "Temporary register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: "Temporary register \(name)."
				)
			),
			RiscvKeyword(
				label: name,
				category: .register,
				documentation: "Temporary register",
				instructionDetail: nil,
				directiveDetail: nil,
				registerDetail: RiscvRegisterDetail(
					number: i,
					usage: "Temporary register \(name)."
				)
			)
		])
	}
	
	return regs
}()
