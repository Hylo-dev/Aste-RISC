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
	private var optionsWrapper: OptionsAssemblerWrapper
	
	let selectedSection: MemorySection.SectionType
    let sections	   : [String: MemorySection]?
	let contentFile	   : String
	
	var body: some View {
        
        if let tempSect = sections,
            let section = tempSect[selectedSection.rawValue] {
            
            switch selectedSection {
                case .stack:
                    StackDetailView(
                        section              : section,
                        callFrames        : self.$stackViewModel.callFrames,
                        stackStores       : self.$cpu.stackStores,
                        stackPointer      : self.cpu.registers[2],
                        framePointer      : self.cpu.registers[8],
                        contentFile       : self.contentFile,
                        textVirtualAddress: self.optionsWrapper.opts?.pointee.text_vaddr ?? 0
                    )
                        
                case .text:
                    TextSectionView(
                        section          : section,
                        programCounter: self.cpu.programCounter
                    )
                        
                case .data:
                    DataSectionView(
                        section: section,
                        ram       : self.cpu.ram
                    )
                        
                case .heap:
                    HeapSectionView(section: section)
            
            }
            
        } else {
                        
            VStack(
                alignment: .leading,
                spacing: 7,
            ) {
                
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fontWeight(.bold)
                    
                    Text("Warning")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                }
                
                Text("Run a file to see \(selectedSection.rawValue) section")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Divider()
        }
	}
}
