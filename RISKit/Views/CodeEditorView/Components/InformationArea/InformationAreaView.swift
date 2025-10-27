//
//  InformationAreaView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import SwiftUI

struct InformationAreaView: View {
	@StateObject private var informationAreaViewModel = InformationAreaViewModel()
	
	var body: some View {
		VStack(spacing: 16) {
			HeaderNavigationBarView(selectedSection: self.$informationAreaViewModel.selectedSection)
			
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
		switch self.informationAreaViewModel.selectedSection {
			case .tableRegisters:
				basePicker()
					.padding(.horizontal)
				
				Divider()
				
			case .stack:
				Divider()
		}
	}
	
	@ViewBuilder /// Show selected view
	private func currentView() -> some View {
		switch self.informationAreaViewModel.selectedSection {
			case .tableRegisters:
				TableRegistersView()
					.environmentObject(self.informationAreaViewModel)
						 
			case .stack:
				MemoryMapView()
		}
	}
	
	@ViewBuilder /// Picker contains all number case available's
	private func basePicker() -> some View {
		Picker("Number base", selection: self.$informationAreaViewModel.numberBaseUsed) {
			
			ForEach(NumberBaseReg.allCases, id: \.id) { base in
				Text(base.rawValue).tag(base)
			}
			
		}
	}
}
