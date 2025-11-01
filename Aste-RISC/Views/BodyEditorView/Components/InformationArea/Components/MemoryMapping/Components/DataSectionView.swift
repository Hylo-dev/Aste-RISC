//
//  DataSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct DataSectionView: View {
	let section: MemorySection
	@EnvironmentObject var cpu: CPU
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(".data (Globals)")
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
				LazyVStack(spacing: 2) {
					ForEach(0..<Int(section.size / 4), id: \.self) { index in
						let addr = section.startAddress + UInt32(index * 4)
						if let ram = cpu.ram {
							let value = read_ram32bit(ram, addr)
							MemoryWordRow(address: addr, value: value)
						}
					}
				}
				.padding()
			}
		}
	}
}
