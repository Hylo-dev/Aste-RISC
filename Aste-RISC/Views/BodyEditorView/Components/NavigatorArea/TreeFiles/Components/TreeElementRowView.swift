//
//  DirectoryRow.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

/// A view that represents a single row (a file or directory) in a recursive
/// file tree.
///
/// This view handles its own indentation, selection state, expansion
/// (if it's a directory), and recursion for its children.
struct TreeElementRowView: View {
	
	/// The data model for this row, representing a file or directory.
	/// This is an `ObservedObject` so the view redraws when `isExpanded`
	/// changes.
	@ObservedObject
	var node: FileNode
	
	/// View model for manage single row on folder
	@ObservedObject
	var viewModel: TreeElementViewModel
	
	@FocusState
	private var isTextFieldFocused: Bool

	/// The URL of the file currently open in the main editor.
	/// This is used to coordinate selection and expansion when the file
	/// is changed externally.
	var fileOpen: URL?
	
	/// The current indentation level (depth) of this node in the tree.
	var level: Int
	
	/// A callback closure executed when a user clicks on a file row
	/// (not a directory) to open it.
	var onOpenFile: ((URL) -> Void)
	
	/// The editor state, this control if the navigation is focused.
	private let isFocused: Bool
	
	init(
		node	  : FileNode,
		viewModel : TreeElementViewModel,
		fileOpen  : URL?,
		level	  : Int,
		isFocused : Bool,
		onOpenFile: @escaping (URL) -> Void
		
	) {
		self.node		= node
		self.viewModel  = viewModel
		self.fileOpen   = fileOpen
		self.level		= level
		self.isFocused  = isFocused
		self.onOpenFile = onOpenFile
	}

	var body: some View {
		
		VStack(alignment: .leading, spacing: 0) {
			
			
			// The main clickable button for the entire row.
			// The visual content of the row
			Button(action: handleOnSelectRow) { bodyButtonElement }
				.buttonStyle(.plain)
				.background(backgroundButton)
				.onChange(of: self.fileOpen) { _, newValue in
					// If the globally open file changes to this node's URL,
					// update the selection state to match.
					if newValue == self.node.url {
						self.viewModel.rowSelected  = self.node.id.uuidString
						self.viewModel.nodeSelected = node
					}
				}
				.onChange(of: self.viewModel.focusedNodeID) { _, newID in
					self.isTextFieldFocused = (newID == self.node.id)
				}
				.onAppear(perform: handleOnAppear)
				.contextMenu { self.contextMenu } // Right clik button
			
			// --- Recursive Child View ---
			// If this node is an expanded directory, render its children.
			if self.node.isDirectory {
				
				VStack(spacing: 0) {
					
					if self.node.isExpanded {
						ForEach(
							self.node.children.filter { $0.matchesFilter(self.viewModel.filterText)
							}
						) { child in
							// Recursively create a new row for each child
							TreeElementRowView(
								node	  : child,
								viewModel : self.viewModel,
								fileOpen  : self.fileOpen,
								level	  : self.level + 1, // Indentation level
								isFocused : self.isFocused,
								onOpenFile: self.onOpenFile
							)
							.transition(
								.move(edge: .top).combined(with: .opacity)
							)
						}
					}
				}
				.frame(maxWidth: .infinity)
				.clipped()
				.animation(
					.spring(
						response	   : 0.1,
						dampingFraction: 0.7
					),
					value: self.node.isExpanded
				)
			}
		}
		.clipped()
	}

	// MARK: - Views
	
	private var backgroundButton: some View {
		let colorButton = self.viewModel.rowSelected ==
						  self.node.id.uuidString ?
									   self.isFocused ?
									   Color.accentColor :
									      .gray.opacity(0.18) : .clear
		
		// Apply a background highlight if this row's level
		// matches the currently selected level.
		return RoundedRectangle(cornerRadius: 8).fill(colorButton)
		
	}
	
	/// Content of right menu for single row on files tree
	private var contextMenu: some View {
		Group {
			
			// MARK: - Show in Finder
			
			Button {
				
				
			} label: { Label("Show in Finder", systemImage: "finder") }
			
			Divider()
			
			// MARK: - File's section
			
			Button {
				self.viewModel.createFile()
				
			} label: {
				Label("New Empty File", systemImage: "document.badge.plus")
			}
			
			Divider()
			
			// MARK: - Options section
			
			Button {
				self.viewModel.deleteFile()
				
			} label: { Label("Delete", systemImage: "trash") }
			
			Button {
				self.viewModel.isChangeName	   	  = true
				self.viewModel.currentFileName 	  = node.name
				self.viewModel.focusedNodeID   	  = node.id
				
			} label: { Label("Rename", systemImage: "pencil") }
			
			Divider()
			
			// MARK: - Folder's options
			
			Button {
				
				
			} label: {
				Label("New Folder", systemImage: "folder.badge.plus")
			}
		}
	}

	/// The visual content of the clickable row, including indentation, icons,
	/// and text.
	private var bodyButtonElement: some View {
		return HStack(spacing: 7) {
			// --- Indentation ---
			// Create horizontal spacing based on the current level.
			// Directories get slightly more indentation per level.
			Color.clear.frame(
				width: CGFloat(level) *
					   CGFloat(self.node.isDirectory ? 20 : 12),
				height: 1
			)
			
			// --- Icons ---
			HStack(spacing: 7) {
				// Renders the chevron (for directories)
				// or a spacer (for files)
				isDirectoryIcon
				
				// Renders the file/folder icon from a shared cache
				if self.node.isDirectory {
					Image(systemName: "folder.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 15, height: 15)
						.if(self.viewModel.rowSelected != self.node.id.uuidString, transform: { view in
							view.foregroundStyle(.tint)
						})
					
				} else {
					Image(
						nsImage: IconCache.shared.icon(
							for: self.node.url
						)
					)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 15, height: 15)
				}
			}
			
			if self.viewModel.isChangeName && self.viewModel.rowSelected == self.node.id.uuidString {
				TextField(self.node.name, text: self.$viewModel.currentFileName)
					.background(
						Rectangle()
							.fill(.background)
					)
					.textFieldStyle(.plain)
					.focused($isTextFieldFocused)
					.onSubmit {
						self.viewModel.renameFile(self.node) { newURL, newName in
							self.node.url 				 = newURL
							self.node.name 				 = newName
							self.viewModel.focusedNodeID = nil
							
							onOpenFile(self.node.url)
						}
					}
				
			} else {
				
				// --- Name ---
				Text(
					node.name.isEmpty ?
						 AttributedString(node.url.path) :
						 node.name.highlightingMatches(of: viewModel.filterText)
				)
				.font(.body)
				.if(self.viewModel.filterText != "", transform: { view in
					view.foregroundStyle(.secondary)
				})
				.lineLimit(1)
				.onTapGesture {
					if self.viewModel.rowSelected == self.node.id.uuidString {
						self.viewModel.isChangeName	   = true
						self.viewModel.currentFileName = node.name
						self.viewModel.focusedNodeID   = node.id
						
					} else { handleOnSelectRow() }
				}
			}
			
			Spacer(minLength: 0)
			
		}
		.padding(.vertical, 5)
		.frame(maxWidth: .infinity, alignment: .leading)
		.contentShape(Rectangle()) // Ensures the whole row is tappable
	}

	/// Renders the disclosure chevron (`>`) for directories or an alignment
	/// spacer for files.
	private var isDirectoryIcon: some View {
		return Group {
			if node.isDirectory {
				
				Button(action: {
					// This gesture *only* handles expansion/collapse.
					// Tapping the main row handles selection.
					if node.isDirectory {
						withAnimation(.spring()) {
							node.isExpanded.toggle()
							// Load children if expanding for the first time
							if node.isExpanded {
								node.loadChildrenPreservingState(
									forceReload: false
								)
							}
						}
					}
					
				}) {
					// --- Directory Chevron ---
					Image(systemName: "chevron.right")
						.font(.caption)
						.fontWeight(.bold)
						.foregroundStyle(.secondary)
						.contentShape(Rectangle())
					
					// Rotate the chevron when the node is expanded
						.rotationEffect(.degrees(self.node.isExpanded ? 90 : 0))
						.animation(
							.spring(
								response: 0.1,
								dampingFraction: 0.7
							),
							value: self.node.isExpanded
						)
				}
				.buttonStyle(.plain)
				
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
		if self.fileOpen == self.node.url {
			self.viewModel.rowSelected  = self.node.id.uuidString
			self.viewModel.nodeSelected = node
		}
	}
	
	/// Handles task on row is selected for first time, set focus row and
	/// set variables
	/// for modified the file title
	private func handleOnSelectRow() {
		// If this node is a file, trigger the open file callback.
		if !self.node.isDirectory {
			onOpenFile(node.url)
		}
		
		// Tapping the row always selects it.
		self.viewModel.rowSelected  = self.node.id.uuidString
		self.viewModel.nodeSelected = node
		self.viewModel.isChangeName = false
		
		self.viewModel.focusedNodeID = node.id
	}
}
