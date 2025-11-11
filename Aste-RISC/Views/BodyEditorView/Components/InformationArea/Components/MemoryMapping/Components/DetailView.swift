//
//  DetailView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct DetailView: View {
	@EnvironmentObject
	private var cpu: CPU
	
	@EnvironmentObject
	private var stackViewModel: StackViewModel
	
	@EnvironmentObject
	var optionsWrapper: OptionsAssemblerWrapper
	
	let selectedSection: MemorySection.SectionType?
	let sections	   : [MemorySection]
	let contentFile	   : String
	
	var body: some View {
		Group {
			if let sectionType = selectedSection,
			   let section = sections.first(where: { $0.type == sectionType }) {
				
				switch sectionType {
					case .stack:
						StackDetailView(
							section			  : section,
							callFrames  	  : self.$stackViewModel.callFrames,
							stackStores 	  : self.$cpu.stackStores,
							stackPointer	  : self.cpu.registers[2],
							framePointer	  : self.cpu.registers[8],
							contentFile 	  : self.contentFile,
							textVirtualAddress: self.optionsWrapper.opts?.pointee.text_vaddr ?? 0
						)
							
					case .text:
						TextSectionView(
							section		  : section,
							programCounter: self.cpu.programCounter
						)
							
					case .data:
						DataSectionView(
							section: section,
							ram	   : self.cpu.ram
						)
							
					case .heap:
						HeapSectionView(section: section)
							
				}
				
			} else {
				HStack(spacing: 7) {
					Image(systemName: "exclamationmark.triangle")
						.font(.system(size: 60))
						.foregroundColor(.secondary)
					
					Text("Run a file to see \(selectedSection!.rawValue)")
						.foregroundColor(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.horizontal)
			}
		}
	}
}
