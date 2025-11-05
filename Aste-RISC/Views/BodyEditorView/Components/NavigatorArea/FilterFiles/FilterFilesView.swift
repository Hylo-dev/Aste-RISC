//
//  FilterFilesView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/11/25.
//

import SwiftUI

struct FilterFilesView: View {
	
	/// String filtering tree file's
	@ObservedObject
	var treeElementViewModel: TreeElementViewModel
	
	/// show popup for create files and folders
	@State
	private var showPopover = false
	
	var body: some View {
		
		HStack(spacing: 5) {
			
			// Button for add item's on tree view
			Menu {
				Button {
					self.treeElementViewModel.createFile()
					
				} label: { Label("New Empty File", systemImage: "document.badge.plus") }
				
				Button {
					
				} label: {
					Label("New Folder", systemImage: "folder.badge.plus")
				}
				
			} label: {
				Image(systemName: "plus")
			}
			.menuIndicator(.hidden)
			.menuStyle(.borderlessButton)
			
			// Filtring files
			HStack {
				TextField("Filter", text: self.$treeElementViewModel.filterText)
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
