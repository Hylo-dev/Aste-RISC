//
//  MemoryBarView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct MemoryBarView: View {
	let sections: [MemorySection]
	@Binding var selectedSection: MemorySection.SectionType?
	
	var body: some View {
		HStack {
			ForEach(Array(sections.enumerated()), id: \.1.id) { index, item in
				buttonNavigation(item)

				if index != sections.count - 1 { Spacer() }
			}
			
		}
		.frame(maxWidth: .infinity)
		.background(
			RoundedRectangle(cornerRadius: 10)
				.fill(.ultraThinMaterial)
				.shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
		)
		.padding(.horizontal)
	}
	
	@ViewBuilder
	private func buttonNavigation(_ section: MemorySection) -> some View {
		
		Button {
			self.selectedSection = section.type
			
		} label: {
			Text(section.name)
				.padding(.vertical, 4)
				.padding(.horizontal, 8)
				.background(
					selectedSection == section.type
						? Color.accentColor
						: Color(.clear)
				)
				.foregroundColor(
					selectedSection == section.type
						? .white
						: .primary
				)
				.cornerRadius(8)
				.animation(.easeInOut(duration: 0.15), value: selectedSection)
			
		}
		.buttonStyle(.plain)
		
	}

}
