//
//  TextSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct TextSectionView: View {
	let section: MemorySection
	
	/// Cpu program counter
	let programCounter: UInt32
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(".text (Code)")
					.font(.title2)
					.foregroundStyle(.green)
					.fontWeight(.bold)
				
				Spacer()
				
				VStack(alignment: .trailing) {
					Text("Address range")
						.font(.subheadline)
						.foregroundStyle(.secondary)

					Text("0x\(String(format: "%08x", section.startAddress)) - 0x\(String(format: "%08x", section.endAddress))")
						.font(.caption)
						.foregroundStyle(.secondary)
						.monospacedDigit()
				}
				
			}
			.padding()
			
			Divider()
			
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text("Program instructions")
						.font(.headline)
						.foregroundColor(.secondary)
					
					Spacer()
				}
				
				HStack {
					Text("PC:")
						.font(.caption)
						.foregroundColor(.secondary)
					
					Text("0x\(String(format: "%08x", programCounter))")
						.font(.caption)
						.monospacedDigit()
						.foregroundColor(
							programCounter >= section.startAddress &&
							programCounter < section.endAddress ?
								.green : .red
						)
					
					Spacer()
					
					if programCounter >= section.startAddress && programCounter < section.endAddress {
						Label("Active", systemImage: "checkmark.circle.fill")
							.font(.caption)
							.foregroundColor(.green)
					}
					
				}
				.padding(.horizontal, 8)
				.background(.background)

			}
			.padding(.horizontal)
			.padding(.vertical, 5)
		}
	}
}
