//
//  BodyEditorViewModel.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation
internal import Combine
import SwiftUI

/// Manages the state and business logic for the `BodyEditorView`.
///
/// This ViewModel serves as the central hub for UI state (like search and editor status)
/// and coordinates with the underlying C-based assembler logic via
/// the `optionsWrapper`. It responds to changes in the CPU's program counter
/// and the currently selected file.
class BodyEditorViewModel: ObservableObject {
	
	/// The URL of the currently open file, persisted across app launches.
	@AppStorage("lastFileOpen")
	var fileSelected: URL?
	
	/// Tracks whether the file search (Spotlight) overlay is active.
	@Published
	var isSearchingFile: Bool
	
	/// Represents the current state of the editor and build process (e.g., `.readyToBuild`, `.running`).
	@Published
	var editorState: EditorState
	
	/// Controls the visibility of the terminal/output panel.
	@Published
	var isOutputVisible: Bool
	
	/// A wrapper for the C-pointer (`opts`) containing assembler and linker
	/// options for the current file.
	@Published
	var optionsWrapper: OptionsAssemblerWrapper
	 
	/// Creates a new view model with a default initial state.
	init() {
		self.isSearchingFile = false
		self.editorState     = .readyToBuild
		self.isOutputVisible = false
		self.optionsWrapper  = OptionsAssemblerWrapper()
	}
		   
	// MARK: - Handles
	
	/// Responds to changes in the currently selected file.
	///
	/// This function manages the lifecycle of the C-based `optionsWrapper`. It
	/// frees the options for the old file (if any) and then initializes new options
	/// for the newly selected file by calling the C-bridge function `start_options`.
	///
	/// - Parameters:
	///   - oldValue: The previously selected file URL (unused).
	///   - newValue: The newly selected file URL.
	func handleFileSelectionChange(
		oldValue: URL?,
		newValue: URL?
	) {
		// Free memory for the previous file's options
		if self.optionsWrapper.opts != nil {
			free_options(self.optionsWrapper.opts)
			self.optionsWrapper.opts = nil
		}
		
		guard let newValue = newValue else { return }
		
		// Create new options for the new file
		newValue.path.withCString { pathAsCString in
			self.optionsWrapper.opts = start_options(UnsafeMutablePointer(mutating: pathAsCString))
		}
	}
	
	func handleisReady() -> Bool {
		return self.editorState == .readyToBuild ||
			   self.editorState == .stopped
	}
}
