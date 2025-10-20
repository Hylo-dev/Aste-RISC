//
//  BodyEditorViewModel.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation
internal import Combine

class BodyEditorViewModel: ObservableObject {
    @Published private(set) var isSearchingFile    : Bool         // Searching File
    @Published private(set) var editorState        : EditorStatus // Runnig section
    @Published private(set) var currentFileSelected: URL?         // Tree file section
    
    init() {
        self.isSearchingFile     = false
        self.editorState         = .readyToBuild
        self.currentFileSelected = nil
    }
    
    func isSearching      (_ status: Bool)         { self.isSearchingFile     = status }
    func changeEditorState(_ state : EditorStatus) { self.editorState         = state  }
    func changeOpenFile   (_ file  : URL)          { self.currentFileSelected = file   }
    
    func isEditorStopped() -> Bool { return self.editorState == .readyToBuild || self.editorState == .stopped }
    
    func toggleSearching() { self.isSearchingFile.toggle() }
}
