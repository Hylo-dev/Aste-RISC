//
//  RiscvKeyword.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

struct RiscvKeyword {
	/// Label keyword
	let label: String
	
	/// Category for keyword
	let category: RiscvCategory
	
	/// Documentation for keyword
	let documentation: String
	
	/// Detail if keyword is instruction
	let instructionDetail: RiscvInstructionDetail?
	
	/// Detail if keyword is directive
	let directiveDetail: RiscvDirectiveDetail?
	
	/// Detail if keyword is register
	let registerDetail: RiscvRegisterDetail?
	
	init(
		label			 : String,
		category		 : RiscvCategory,
		documentation	 : String,
		instructionDetail: RiscvInstructionDetail? = nil,
		directiveDetail	 : RiscvDirectiveDetail? = nil,
		registerDetail	 : RiscvRegisterDetail? = nil
		
	) {
		self.label 			   = label
		self.category 		   = category
		self.documentation 	   = documentation
		self.instructionDetail = instructionDetail
		self.directiveDetail   = directiveDetail
		self.registerDetail    = registerDetail
		
	}
}
