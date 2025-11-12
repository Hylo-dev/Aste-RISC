//
//  NavigatiorAreaView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 03/11/25.
//

import SwiftUI

/// A SwiftUI view that acts as the main container for the file navigation area.
///
/// This view is responsible for displaying the `TreeFilesView` and managing
/// the state of the currently selected file via a binding.
struct NavigatiorAreaView: View {
	
	/// A binding to the URL of the currently selected file.
	///
	/// This property syncs the selection state between this view, its parent
	/// (like an editor container), and the child `TreeFilesView`.
	@Binding
	private var fileSelected: URL?
	
	/// ViewModel for manage the status row's
	@StateObject
	private var treeElementViewModel = TreeElementViewModel()
	
	/// The absolute file path to the root directory of the project.
	/// This path is passed to `TreeFilesView` to populate the file tree.
	private let projectPath: String
	
	/// The editor state, this control if the navigation is focused.
	private let isFocused: Bool
	
	/// Initializes a new navigator area view.
	///
	/// - Parameters:
	///   - fileSelected: A `Binding` to an optional `URL` that represents the
	///     currently active or selected file.
	///   - projectPath: A `String` representing the file system path
	///     to the project's root directory.
	init(
		fileSelected: Binding<URL?>,
		projectPath : String,
		isFocused	: Bool
	) {
		self._fileSelected = fileSelected
		self.projectPath   = projectPath
		self.isFocused	   = isFocused
	}
	
	/// The body of the view, which constructs the layout.
	var body: some View {
		
		VStack {
			// The primary view that renders the actual file tree.
			// It is initialized with the project path and the file selection binding.
			TreeFilesView(
				treeElementViewModel: self.treeElementViewModel,
				projectPath		    : self.projectPath,
				selectedFile		: self.$fileSelected,
				isFocused			: self.isFocused
				
			) { newURL in
				// This closure is called by TreeFilesView when a user
				// selects a different file, updating the parent's state.
				self.fileSelected = newURL
			}
			.padding(.horizontal, 10) // Adds horizontal padding to the entire sidebar
			
			// Pushes the TreeFilesView to the top of the VStack
			Spacer()
			
			Divider()
			
			FilterFilesView(treeElementViewModel: self.treeElementViewModel)
		}
		
	}
}
