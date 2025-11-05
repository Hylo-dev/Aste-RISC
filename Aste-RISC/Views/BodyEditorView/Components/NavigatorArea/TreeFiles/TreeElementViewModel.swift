//
//  TreeElementViewModel.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/11/25.
//

import Foundation
internal import Combine

class TreeElementViewModel: ObservableObject {
	
	/// Tracks the currently focused row.
	@Published
	var rowSelected: Int
	
	/// Control name, set to change, if true then set texfield
	@Published
	var isChangeName: Bool
	
	/// File selected name and extension
	@Published
	var currentFileName: String
	
	/// Use for filtering file with name
	@Published
	var filterText: String
	
	init() {
		
		// Default values
		self.rowSelected 	 = 0
		self.isChangeName    = false
		self.currentFileName = ""
		self.filterText 	 = ""
	}
	
	/// Rename the file or directory
	func renameFile(_ node: FileNode, done: (_ newURL: URL, _ newName: String) -> Void) {
		guard !self.currentFileName.isEmpty else { return }
		
		let fileManager   = FileManager.default
		let directory     = node.url.deletingLastPathComponent()
		
		let newURL = directory.appendingPathComponent(self.currentFileName)
		
		guard newURL != node.url else {
			self.isChangeName = false
			
			return
		}
		
		do {
			try fileManager.moveItem(at: node.url, to: newURL)
			self.isChangeName = false
			
			done(newURL, self.currentFileName)
									
		} catch {
			print("Error rename: \(error.localizedDescription)")
			
		}
	}
}
