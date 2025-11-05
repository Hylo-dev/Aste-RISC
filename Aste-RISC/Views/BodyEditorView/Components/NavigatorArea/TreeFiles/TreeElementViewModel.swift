//
//  TreeElementViewModel.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/11/25.
//

import Foundation
internal import Combine

class TreeElementViewModel: ObservableObject {
	
	/// Tracks the currently focused node.
	@Published
	var nodeSelected: FileNode?
	
	/// Node ID, have single row id
	@Published
	var focusedNodeID: UUID? = nil
	
	/// Tracks the currently focused row.
	@Published
	var rowSelected: String
	
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
		self.rowSelected 	 = ""
		self.nodeSelected 	 = nil
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
	
	func createFile() {
		guard let selectedNode = nodeSelected else { return }

		let fileManager = FileManager.default

		let parentNode: FileNode
		if selectedNode.isDirectory {
			parentNode = selectedNode

		} else {
			guard let parent = selectedNode.parent else { return }
			parentNode = parent
		}

		var fileName = "untitled.s"
		var counter = 1
		var newURL = parentNode.url.appendingPathComponent(fileName)

		while fileManager.fileExists(atPath: newURL.path) {
			fileName = "untitled\(counter).s"
			newURL = parentNode.url.appendingPathComponent(fileName)
			counter += 1
		}

		if fileManager.createFile(atPath: newURL.path, contents: nil) {

			if !parentNode.isExpanded {
				parentNode.isExpanded = true
			}
			
			parentNode.loadChildrenPreservingState(forceReload: true)

			Task { @MainActor in
				try? await Task.sleep(nanoseconds: 100_000_000)
				
				if let newNode = parentNode.children.first(where: { $0.url == newURL }) {
					self.nodeSelected    = newNode
					self.rowSelected	 = newNode.id.uuidString
					self.isChangeName    = true
					self.currentFileName = newNode.name
					self.focusedNodeID   = newNode.id
				}
			}
		}
	}
	
	/// Delete the file/directory of the selected node and select the previous one
	func deleteFile() {
		guard let selectedNode = nodeSelected else { return }
		
		let fileManager = FileManager.default
		let parentNode = selectedNode.parent
		
		var previousNode: FileNode?
		if let parent = parentNode,
		   let currentIndex = parent.children.firstIndex(where: { $0.id == selectedNode.id }) {
			
			if currentIndex > 0 {
				previousNode = parent.children[currentIndex - 1]
				
			} else if parent.children.count > 1 {
				previousNode = parent.children[currentIndex + 1]
				
			} else {
				previousNode = parent
			}
		}
		
		do {
			try fileManager.removeItem(at: selectedNode.url)
			
			if let parent = parentNode {
				parent.loadChildrenPreservingState(forceReload: true)
			}
			
			Task { @MainActor in
				try? await Task.sleep(nanoseconds: 100_000_000)
				
				if let prevNode = previousNode {
					self.nodeSelected  = prevNode
					self.rowSelected   = prevNode.id.uuidString
					self.focusedNodeID = prevNode.id
					
				} else {
					// No node to select
					self.nodeSelected  = nil
					self.rowSelected   = ""
					self.focusedNodeID = nil
				}
			}
			
		} catch {
			print("Error deleting file: \(error.localizedDescription)")
		}
	}
	
}
