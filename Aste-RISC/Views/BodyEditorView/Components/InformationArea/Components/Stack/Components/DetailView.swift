//
//  DetailView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

// Vista dettagliata per ogni sezione
struct DetailView: View {
	let selectedSection: MemorySection.SectionType?
	let sections: [MemorySection]
	
	@EnvironmentObject var cpu: CPU
	
	var body: some View {
		Group {
			if let sectionType = selectedSection,
			   let section = sections.first(where: { $0.type == sectionType }) {
				
				switch sectionType {
				case .stack:
					StackDetailView(section: section)
						
				case .text:
					TextSectionView(section: section)
						
				case .data:
					DataSectionView(section: section)
						
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
