//
//  InformationAreaViewModel.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import Foundation
internal import Combine

@MainActor
class InformationAreaViewModel: ObservableObject {
	@Published var selectedSection  : InformationNavigation     = .tableRegisters
	@Published var numberBaseUsed   : NumberBaseReg		        = .hex
	@Published var memoryMapSelected: MemorySection.SectionType = .stack
	
	static let registerName = riscvRegisters.filter { !$0.label.contains("x") && $0.label != "zero" }

	/// Get string formatted for number base selected
	func baseFormatted(_ value: Int) -> String {
		return switch numberBaseUsed {
			case .dec: String(value, radix: numberBaseUsed.base, uppercase: true)
							
			case .bin: "0b" + String(value, radix: numberBaseUsed.base, uppercase: true)
						
			case .hex: "0x" + String(value, radix: numberBaseUsed.base, uppercase: true)
							
			case .oct: "0o" + String(value, radix: numberBaseUsed.base, uppercase: true)
		
		}
	}
}
