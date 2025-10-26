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
					
					let value = self.cpu.registers[register.registerDetail!.number]
					Text(self.informationAreaViewModel.baseFormatted(value))
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
}
