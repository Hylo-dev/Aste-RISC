//
//  TableRegistersView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import SwiftUI

struct TableRegistersView: View {
	@EnvironmentObject private var cpu: CPU
	@EnvironmentObject private var informationAreaViewModel: InformationAreaViewModel
	
	@State private var registersChanged: Int = -1
	
	var body: some View {
				
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
		
			ForEach(InformationAreaViewModel.registerName, id: \.label) { register in
				
				GridRow {
					Text(register.label)
					
					Spacer()
					
					let regNumber = register.registerDetail!.number
					let isChanged = self.registersChanged == regNumber
					let value     = self.cpu.registers[regNumber]
					Text(self.informationAreaViewModel.baseFormatted(value))
						.foregroundStyle(isChanged ? Color.yellow : Color.primary)
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
		.onChange(of: self.cpu.registers, handleRegistersChanded)
		
	}
	
	private func handleRegistersChanded(
		oldValue: [Int],
		newValue: [Int]
		
	) {
		self.registersChanged = -1
		
		for index in oldValue.indices {
			
			if oldValue[index] != newValue[index] { self.registersChanged = index  }
			
		}
		
	}
}
