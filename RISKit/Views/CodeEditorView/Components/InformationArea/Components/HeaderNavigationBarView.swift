//
//  HeaderNavigationBarView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import SwiftUI

struct HeaderNavigationBarView: View {
	@State private var selectedSection: InformationNavigation = .tableRegisters
	
	var body: some View {
		HStack {
			ForEach(InformationNavigation.allCases, id: \.hashValue) { item in
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
	}
	
	@ViewBuilder
	private func buttonNavigation(_ section: InformationNavigation) -> some View {
		
		Button {
			self.selectedSection = section
			
		} label: {
			Image(systemName: section.rawValue)
				.frame(width: 15, height: 15)
				.padding(.vertical, 4)
				.padding(.horizontal, 8)
				.background(
					selectedSection == section
						? Color.accentColor
						: Color(.clear)
				)
				.foregroundColor(
					selectedSection == section
						? .white
						: .primary
				)
				.cornerRadius(8)
				.animation(.easeInOut(duration: 0.15), value: selectedSection)
			
		}
		.buttonStyle(.plain)
		
	}
}
