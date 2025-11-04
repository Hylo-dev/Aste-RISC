//
//  FilterFilesView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/11/25.
//

import SwiftUI

struct FilterFilesView: View {
	
	/// String filtering tree file's
	@State
	private var filterFiles: String = ""
	
	/// show popup for create files and folders
	@State
	private var showPopover = false
	
	var body: some View {
		
		HStack {
			
			// Button for add item's on tree view
			Menu {
				Button("Modifica") {
					print("Modifica")
				}
				
				Button("Elimina") {
					print("Elimina")
				}
				
			} label: {
				Image(systemName: "plus")
			}
			.menuIndicator(.hidden)
			.menuStyle(.borderlessButton)
			
			// Filtring files
			HStack {
				TextField("Filter", text: $filterFiles)
					.textFieldStyle(.plain)
					.frame(maxWidth: .infinity)
			}
			.padding(.vertical, 7)
			.padding(.horizontal, 10)
			.glassEffect()
			
		}
		.padding(.leading, 15)
		.padding(.trailing, 9)
		.padding(.bottom, 9)
		.padding(.top, 1)
	}
}
