//
//  HeapSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct HeapSectionView: View {
	let section: MemorySection
	
	var body: some View {
		VStack {
			HStack {
				
				VStack(alignment: .leading) {
					Text("Heap")
						.font(.title2)
						.foregroundStyle(.orange)
						.fontWeight(.bold)
					
					Text("\(section.size) Bytes available")
						.font(.caption)
						.foregroundStyle(.secondary)
					
				}
				
				Spacer()
				
				Text("Dynamic allocation area")
					.font(.body)
					.foregroundColor(.secondary)
				
			}
			.padding()
			
			Divider()
		}
	}
}
