//
//  DataSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct DataSectionView: View {
	let section: MemorySection
	let ram	   : RAM?
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Text(".data")
					.font(.title2)
                    .fontDesign(.rounded)
					.foregroundStyle(.cyan)
					.fontWeight(.bold)
				
				Spacer()
				
				if section.size > 0 {
                    VStack(alignment: .trailing) {
                        Text("Address range")
                            .font(.subheadline)
                            .fontDesign(.rounded)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        
                        Text("0x\(String(format: "%08x", section.startAddress)) - 0x\(String(format: "%08x", section.endAddress))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
					
				} else {
					Text("Initialised global data")
						.font(.headline)
                        .fontDesign(.rounded)
						.foregroundStyle(.secondary)
						.monospacedDigit()
					
				}
			}
			.padding()
			
			Divider()
            
            VStack {
                if self.section.size > 0 {
                    ForEach(0 ..< Int(section.size / 4), id: \.self) { index in
                        let addr = section.startAddress + UInt32(index * 4)
                        
                        if let ram = ram {
                            let value = read_ram32bit(ram, addr)
                            MemoryWordRow(address: addr, value: value)
                        }
                    }
                }
            }
            .padding(.horizontal)
		}
	}
}
