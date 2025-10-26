//
//  InformationAreaView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import SwiftUI

struct InformationAreaView: View {
	@State private var selectedSection: InformationNavigation = .tableRegisters
	
	var body: some View {
		VStack(spacing: 16) {
			HeaderNavigationBarView(selectedSection: self.$selectedSection)
						
			ScrollView {
				
				LazyVStack(alignment: .leading) {
					currentView()
				}
			}
		}
	}
	
	@ViewBuilder
	private func currentView() -> some View {
		switch selectedSection {
			case .tableRegisters:
				TableRegistersView()
						 
			case .stack:
				EmptyView()
		}
	}
}
