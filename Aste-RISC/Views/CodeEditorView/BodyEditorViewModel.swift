//
//  BodyEditorViewModel.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation
internal import Combine

class BodyEditorViewModel: ObservableObject {
    @Published private(set) var isSearchingFile    : Bool            // Searching File
    @Published private(set) var editorState        : EditorState    // Runnig section
    @Published private(set) var currentFileSelected: URL?            // Tree file section
    @Published private(set) var mapInstruction     : MapInstructions // Map instruction source to view
	@Published 		 		var isOutputVisible	   : Bool			 // Show output section
    
    init() {
        self.isSearchingFile     = false
        self.editorState         = .readyToBuild
        self.currentFileSelected = nil
        self.mapInstruction      = MapInstructions()
		self.isOutputVisible 	 = false
    }
    
    func isSearching      (_ status: Bool)         { Task { @MainActor in self.isSearchingFile     = status } }
    func changeEditorState(_ state : EditorState) { Task { @MainActor in self.editorState         = state  } }
    func changeOpenFile   (_ file  : URL)          { Task { @MainActor in self.currentFileSelected = file   } }
    
    func isEditorStopped() -> Bool { return self.editorState == .readyToBuild || self.editorState == .stopped }
    
    func toggleSearching() { self.isSearchingFile.toggle() }
    
    // MARK: Map instruction handles
    func changeCurrentInstruction(index: UInt32?) { self.mapInstruction.indexInstruction = index }
    func appendInstruction(_ value: Int)          { self.mapInstruction.indexesInstructions.append(value) }
    func cleanInstructionsMapped()                { self.mapInstruction.indexesInstructions.removeAll() }
}
