//
//  TreeView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

/// A view that displays a collapsible file system hierarchy starting from a root directory.
///
/// This view renders a `LazyVStack` of `TreeElementRowView` instances, allowing
/// for navigation, expansion, and selection of files and directories.
///
/// It automatically loads the root directory's contents on appear and observes
/// changes to the `selectedFile` binding, expanding the tree as needed to
/// reveal the currently active file.
struct TreeFilesView: View {
	
	/// The root model node of the file tree.
	@StateObject
	private var rootNode: FileNode
	
	/// Tracks the currently focused row (e.g., for keyboard navigation).
	@State
	private var rowSelected: Int = 0
	
	/// A binding to the URL of the file currently considered "open" or "active"
	/// in the wider application.
	@Binding
	private var selectedFile: URL?
	
	/// A closure executed when the user attempts to open a file (e.g., by double-clicking).
	private var onOpenFile: ((URL) -> Void)
	 
	/// Creates the file tree view.
	///
	/// - Parameters:
	///   - projectPath: The absolute string path to the root directory to display.
	///   - selectedFile: A binding to the currently active file URL.
	///   - onOpenFile: A callback invoked when a file is selected for opening.
	init(
		projectPath   : String,
		selectedFile  : Binding<URL?>,
		onOpenFile    : @escaping ((URL) -> Void)
	) {
		self._rootNode      = StateObject(wrappedValue: FileNode(url: URL(fileURLWithPath: projectPath)))
		self._selectedFile = selectedFile
		self.onOpenFile     = onOpenFile
	}

	var body: some View {
		ScrollView {
			LazyVStack(alignment: .leading, spacing: 5) {
				TreeElementRowView(
					node       : self.rootNode,
					isSelected : self.$rowSelected,
					fileOpen   : self.selectedFile,
					level      : 0,
					onOpenFile : self.onOpenFile
				)
				
			}
			.padding(.vertical, 8)
			.padding(.horizontal, 4)
			
		}
		.frame(minWidth: 220)
		.padding(.horizontal, 10)
		.onAppear {
			guard self.rootNode.isDirectory else { return }

			self.rootNode.loadChildrenPreservingState(forceReload: true)
			self.rootNode.isExpanded = true
		}
		.onChange(of: self.selectedFile) { _, newURL in
			// When the externally selected file changes,
			// expand the tree to reveal it.
			guard let urlToOpen = newURL else { return }
			_ = self.rootNode.expandTo(url: urlToOpen)
		}
	}
}
