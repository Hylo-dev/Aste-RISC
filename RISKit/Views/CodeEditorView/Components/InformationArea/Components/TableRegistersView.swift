//
//  TableRegistersView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import SwiftUI

struct TableRegistersView: View {
	@EnvironmentObject private var cpu: CPU
	private static let registerName = riscvRegisters.filter { !$0.label.contains("x") && $0.label != "zero" }
	
	@State private var numberBaseUsed: NumberBaseReg = .hex
	
	var body: some View {
		basePicker()
			.padding(.horizontal)
		
		Divider()
				
		Grid(
			alignment		 : .leading,
			horizontalSpacing: 16,
			verticalSpacing  : 8
		) {
			
			GridRow {
				Text("Registers").bold()
				
				Spacer()
				
				Text("Stack").bold()
			}
		
			ForEach(Self.registerName, id: \.label) { register in
				
				GridRow {
					Text(register.label)
					
					Spacer()
					
					let value = self.cpu.registers[register.registerDetail!.number]
					Text(baseFormatted(value))
						.monospaced()
						.lineLimit(1)
					
					
				}
				
				Divider()
			}
		}
		.padding()
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 15))
		.padding(.horizontal)
		.padding(.bottom)
	}
	
	@ViewBuilder /// Picker contains all number case available's
	private func basePicker() -> some View {
		Picker("Number base", selection: $numberBaseUsed) {
			
			ForEach(NumberBaseReg.allCases, id: \.id) { base in
				Text(base.rawValue).tag(base)
			}
			
		}
	}
	
	/// Get string formatted for number base selected
	private func baseFormatted(_ value: Int) -> String {
		return switch numberBaseUsed {
			case .dec: String(value, radix: numberBaseUsed.base, uppercase: true)
							
			case .bin: "0b" + String(value, radix: numberBaseUsed.base, uppercase: true)
						
			case .hex: "0x" + String(value, radix: numberBaseUsed.base, uppercase: true)
							
			case .oct: "0o" + String(value, radix: numberBaseUsed.base, uppercase: true)
		
		}
	}
}
