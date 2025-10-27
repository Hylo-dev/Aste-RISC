//
//  TextSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct TextSectionView: View {
	let section: MemorySection
	@EnvironmentObject var cpu: CPU
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(".text (Code)")
					.font(.title2)
					.fontWeight(.bold)
				Spacer()
				Text("0x\(String(format: "%08x", section.startAddress)) - 0x\(String(format: "%08x", section.endAddress))")
					.font(.caption)
					.monospacedDigit()
			}
			.padding()
			
			Divider()
			
			ScrollView {
				VStack(alignment: .leading, spacing: 8) {
					HStack {
						Text("Istruzioni del programma")
							.font(.subheadline)
							.foregroundColor(.secondary)
						Spacer()
					}
					
					HStack {
						Text("PC:")
							.font(.caption)
							.foregroundColor(.secondary)
						Text("0x\(String(format: "%08x", cpu.programCounter))")
							.font(.caption)
							.monospacedDigit()
							.foregroundColor(cpu.programCounter >= section.startAddress && cpu.programCounter < section.endAddress ? .green : .red)
						
						Spacer()
						
						if cpu.programCounter >= section.startAddress && cpu.programCounter < section.endAddress {
							Label("Attivo", systemImage: "checkmark.circle.fill")
								.font(.caption)
								.foregroundColor(.green)
						}
					}
					.padding(8)
					.background(.background)
					.cornerRadius(6)
				}
				.padding()
			}
		}
	}
}
