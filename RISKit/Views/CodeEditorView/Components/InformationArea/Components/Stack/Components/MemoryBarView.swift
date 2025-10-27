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
	let totalHeight: CGFloat
	
	private var totalMemorySize: UInt32 {
		guard let first = sections.first, let last = sections.last else { return 0 }
		return (last.endAddress - first.startAddress)
	}
	
	var body: some View {
		HStack {
			ForEach(Section) { item in
				buttonNavigation(item)
			}
			
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			RoundedRectangle(cornerRadius: 10)
				.fill(.ultraThinMaterial)
				.shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
		)
		.padding(.horizontal)
		
		VStack(spacing: 1) {
			ForEach(sections) { section in
				let height = calculateHeight(for: section)
				
				Button(action: {
					selectedSection = section.type
				}) {
					VStack(spacing: 2) {
						Text(section.name)
							.font(.caption2)
							.fontWeight(.bold)
						
						Text(formatSize(section.size))
							.font(.caption2)
							.foregroundColor(.secondary)
						
					}
					.frame(maxWidth: .infinity)
					.frame(height: max(height, 30))
					.background(section.color.opacity(selectedSection == section.type ? 0.8 : 0.5))
					.overlay(
						RoundedRectangle(cornerRadius: 4)
							.stroke(selectedSection == section.type ? Color.white : Color.clear, lineWidth: 2)
					)
					.cornerRadius(4)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(4)
	}
	
	private func calculateHeight(for section: MemorySection) -> CGFloat {
		guard totalMemorySize > 0 else { return 0 }
		let ratio = CGFloat(section.size) / CGFloat(totalMemorySize)
		return totalHeight * ratio
	}

}
