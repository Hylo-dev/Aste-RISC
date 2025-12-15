//
//  StackView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import SwiftUI

struct MemoryMapView: View {
	@EnvironmentObject
    var cpu: CPU
    
	@EnvironmentObject
    var informationAreaViewModel: InformationAreaViewModel
	
	let contentFile: String
		
	var body: some View {
		DetailView(
			selectedSection: self.informationAreaViewModel.memoryMapSelected,
			sections	   : self.memorySections,
			contentFile	   : self.contentFile
		)
	}
	
    private var memorySections: [String: MemorySection]? {
        guard let ram = cpu.ram else { return nil }
		
		let ramBase = ram.pointee.base_vaddr
		let ramSize = UInt32(ram.pointee.size)
		let sp 		= UInt32(cpu.registers[2])
		
        var sections: [String: MemorySection] = [:]
		
		// Sezione .text
		if cpu.ram!.pointee.text_size > 0 {
            sections["text"] = MemorySection(
                name: "text",
                startAddress: cpu.ram!.pointee.text_base,
                size: cpu.ram!.pointee.text_size,
                color: .blue,
                type: .text
                
            )
		}
		
		// Sezione .data
		sections["data"] = MemorySection(
            name: "data",
            startAddress: cpu.ram!.pointee.data_base,
            size: cpu.ram!.pointee.data_size,
            color: .green,
            type: .data
        )
		
		// Heap (area tra .data e stack)
		let heapStart = cpu.ram!.pointee.data_base + cpu.ram!.pointee.data_size
		if sp > heapStart {
			let heapSize = sp - heapStart
            
			sections["heap"] = MemorySection(
                name: "heap",
                startAddress: heapStart,
                size: heapSize,
                color: .orange,
                type: .heap
            )
		}
		
		// Stack (da SP fino alla fine della RAM)
		let ramEnd = ramBase + ramSize
		if sp < ramEnd {
			let stackSize = ramEnd - sp
			sections["stack"] = MemorySection(
                name: "stack",
                startAddress: sp,
                size: stackSize,
                color: .purple,
                type: .stack
            )
		}
		
		return sections
	}
}
