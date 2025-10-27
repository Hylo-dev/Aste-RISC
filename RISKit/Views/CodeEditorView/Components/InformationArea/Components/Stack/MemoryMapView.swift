//
//  StackView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import SwiftUI

struct MemoryMapView: View {
	@EnvironmentObject var cpu: CPU
	@State private var selectedSection: MemorySection.SectionType?
	
	var body: some View {
		GeometryReader { geometry in
			VStack(spacing: 6) {
				
				MemoryBarView(
					sections: memorySections,
					selectedSection: $selectedSection,
					totalHeight: geometry.size.height - 100
				)
								
				Divider()
				
				// Dettaglio della sezione selezionata
				DetailView(
					selectedSection: selectedSection,
					sections: memorySections
				)
				.frame(maxWidth: .infinity)
				
			}
			.padding()
		}
	}
	
	private var memorySections: [MemorySection] {
		guard let ram = cpu.ram else { return [] }
		
		let ramBase = ram.pointee.base_vaddr
		let ramSize = UInt32(ram.pointee.size)
		let sp = UInt32(cpu.registers[2])
		
		var sections: [MemorySection] = []
		
		// Sezione .text
		if cpu.textSize > 0 {
			sections.append(MemorySection(
				name: ".text",
				startAddress: cpu.textBase,
				size: cpu.textSize,
				color: .blue,
				type: .text
			))
		}
		
		// Sezione .data
		if cpu.dataSize > 0 {
			sections.append(MemorySection(
				name: ".data",
				startAddress: cpu.dataBase,
				size: cpu.dataSize,
				color: .green,
				type: .data
			))
		}
		
		// Heap (area tra .data e stack)
		let heapStart = cpu.dataBase + cpu.dataSize
		if sp > heapStart {
			let heapSize = sp - heapStart
			sections.append(MemorySection(
				name: "heap",
				startAddress: heapStart,
				size: heapSize,
				color: .orange,
				type: .heap
			))
		}
		
		// Stack (da SP fino alla fine della RAM)
		let ramEnd = ramBase + ramSize
		if sp < ramEnd {
			let stackSize = ramEnd - sp
			sections.append(MemorySection(
				name: "stack",
				startAddress: sp,
				size: stackSize,
				color: .purple,
				type: .stack
			))
		}
		
		return sections
	}
}
