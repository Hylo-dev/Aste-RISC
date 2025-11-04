//
//  InformationAreaView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import SwiftUI
import SegmentedFlowPicker

struct InformationAreaView: View {
	@StateObject private var informationAreaViewModel = InformationAreaViewModel()
	
	var body: some View {
		VStack(spacing: 16) {
			SegmentedFlowPicker(selectedSection: self.$informationAreaViewModel.selectedSection) { section in
				Image(systemName: section.rawValue)
			}
			.buttonFocusedColor(.accentColor)
			.clipShape(.rect(cornerRadius: 10))
			.glassEffect()
			.padding(.top, 5)
			.frame(height: 30)

			VStack(alignment: .leading) {
				scrollHeader()
							
				ScrollView {
					
					LazyVStack {
						currentView()
					}
				}
			}
		}
	}
	
	@ViewBuilder
	private func scrollHeader() -> some View {
		Divider()
		
		switch self.informationAreaViewModel.selectedSection {
			case .tableRegisters:
				SegmentedFlowPicker(selectedSection: self.$informationAreaViewModel.numberBaseUsed) { section in
					Text(section.rawValue).tag(section.base)
						.font(.body)
				}
				.glassEffect()
				.frame(height: 27)
				
			case .stack:
				SegmentedFlowPicker(
					selectedSection: self.$informationAreaViewModel.memoryMapSelected
					
				) { section in
					Text(section.rawValue).tag(section.rawValue)
						.font(.body)
				}
				.glassEffect()
				.frame(height: 27)
		}
		
		Divider()
	}
	
	@ViewBuilder /// Show selected view
	private func currentView() -> some View {
		switch self.informationAreaViewModel.selectedSection {
			case .tableRegisters:
				TableRegistersView()
					.environmentObject(self.informationAreaViewModel)
						 
			case .stack:
				MemoryMapView()
					.environmentObject(self.informationAreaViewModel)
		}
	}
}
