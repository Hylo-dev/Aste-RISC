//
//  HeapSectionView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

// Vista per l'heap
struct HeapSectionView: View {
	let section: MemorySection
	
	var body: some View {
		VStack {
			HStack {
				Text("Heap")
					.font(.title2)
					.fontWeight(.bold)
				Spacer()
			}
			.padding()
			
			Divider()
			
			Spacer()
			
			VStack(spacing: 8) {
				Image(systemName: "arrow.up.and.down")
					.font(.system(size: 40))
					.foregroundColor(.orange)
				Text("Area di allocazione dinamica")
					.foregroundColor(.secondary)
				Text("\(section.size) bytes disponibili")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Spacer()
		}
	}
}
