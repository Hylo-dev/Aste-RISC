//
//  DirectoryRow.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

/// A view that represents a single row (a file or directory) in a recursive file tree.
///
/// This view handles its own indentation, selection state, expansion (if it's a
/// directory), and recursion for its children.
struct TreeElementRowView: View {
	
	/// The data model for this row, representing a file or directory.
	/// This is an `ObservedObject` so the view redraws when `isExpanded` changes.
	@ObservedObject
	var node: FileNode
	
	/// A binding to track selection. The row is considered "selected"
	/// when this value matches its own `level`.
	@Binding
	var isSelected: Int
	
	/// The URL of the file currently open in the main editor.
	/// This is used to coordinate selection and expansion when the file
	/// is changed externally.
	var fileOpen: URL?
	
	/// The current indentation level (depth) of this node in the tree.
	var level: Int
	
	/// A callback closure executed when a user clicks on a file row
	/// (not a directory) to open it.
	var onOpenFile: ((URL) -> Void)

	var body: some View {
		
		VStack(alignment: .leading, spacing: 0) {
			// The main clickable button for the entire row.
			Button(action: {
				// If this node is a file, trigger the open file callback.
				if !self.node.isDirectory {
					onOpenFile(node.url)
				}
				
				// Tapping the row always selects it.
				self.isSelected = level
				
			}) { bodyButtonElement }  // The visual content of the row
				.buttonStyle(.plain)
				.background(
					// Apply a background highlight if this row's level
					// matches the currently selected level.
					RoundedRectangle(cornerRadius: 8)
						.fill(self.isSelected == level ? Color.accentColor : .clear)
				)
				.onChange(of: self.fileOpen) { _, newValue in
					// If the globally open file changes to this node's URL,
					// update the selection state to match.
					if newValue == self.node.url { self.isSelected = level }
				}
				.onAppear(perform: handleOnAppear)
				.contextMenu {
					// Example context menu action
					Button {
						print("Azione 'Modifica' selezionata")
						
					} label: {
						Label("Modifica", systemImage: "pencil")
					}
				}
			
			// --- Recursive Child View ---
			// If this node is an expanded directory, render its children.
			if self.node.isDirectory {
				
				VStack(spacing: 0) {
					if node.isExpanded {
						ForEach(node.children) { child in
							// Recursively create a new row for each child
							TreeElementRowView(
								node: child,
								isSelected: $isSelected,
								fileOpen: fileOpen,
								level: level + 1, // Increment the indentation level
								onOpenFile: onOpenFile
							)
							.transition(.move(edge: .top).combined(with: .opacity))
						}
					}
				}
				.frame(maxWidth: .infinity)
				.clipped()
			}
			
		}
		.clipped()
	}

	// MARK: - Views

	/// The visual content of the clickable row, including indentation, icons, and text.
	private var bodyButtonElement: some View {
		return HStack(spacing: 7) {
			// --- Indentation ---
			// Create horizontal spacing based on the current level.
			// Directories get slightly more indentation per level.
			Color.clear.frame(width: CGFloat(level) * CGFloat(self.node.isDirectory ? 20 : 12), height: 1)
			
			// --- Icons ---
			HStack(spacing: 5) {
				// Renders the chevron (for directories) or a spacer (for files)
				isDirectoryIcon
				
				// Renders the file/folder icon from a shared cache
				if self.node.isDirectory {
					Image(systemName: "folder.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 15, height: 15)
						.if(self.isSelected != level, transform: { view in
							view.foregroundStyle(.tint)
						})
					
				} else {
					Image(nsImage: IconCache.shared.icon(for: node.url))
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 15, height: 15)
				}
			}
			
			// --- Name ---
			Text(node.name.isEmpty ? node.url.path : node.name)
				.font(.body)
				.lineLimit(1)
			
			Spacer(minLength: 0)
			
		}
		.padding(.vertical, 5)
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle()) // Ensures the whole row is tappable
	}

	/// Renders the disclosure chevron (`>`) for directories or an alignment spacer for files.
	private var isDirectoryIcon: some View {
		return Group {
			if node.isDirectory {
				// --- Directory Chevron ---
				Image(systemName: "chevron.right")
					.font(.caption)
					.fontWeight(.bold)
					.foregroundStyle(.secondary)
					.padding(3)
					.contentShape(Rectangle())
				
				// Rotate the chevron when the node is expanded
					.rotationEffect(.degrees(self.node.isExpanded ? 90 : 0))
					.animation(.spring(response: 0.2, dampingFraction: 0.7), value: self.node.isExpanded)
					.onTapGesture {
						// This gesture *only* handles expansion/collapse.
						// Tapping the main row handles selection.
						if node.isDirectory {
							withAnimation(.spring()) {
								node.isExpanded.toggle()
								// Load children if expanding for the first time
								if node.isExpanded { node.loadChildrenPreservingState(forceReload: false) }
							}
						}
					}
				
			} else {
				// --- File Spacer ---
				// Add a clear spacer to align files with directory text
				Color.clear.frame(width: 12, height: 12)
			}
		}
	}
	
	// MARK: - Handles
	
	/// Handles tasks on view appearance, such as expanding the tree to a
	/// selected file or setting the initial selection state.
	private func handleOnAppear() {
		// If an open file is set and this node is not expanded,
		// try to expand the tree *to* that file.
		if let file = fileOpen, !self.node.isExpanded {
			_ = self.node.expandTo(url: file)
		}
		
		// If this row's node *is* the currently open file,
		// set its selection state.
		if self.fileOpen == self.node.url { self.isSelected = level }
	}
}
