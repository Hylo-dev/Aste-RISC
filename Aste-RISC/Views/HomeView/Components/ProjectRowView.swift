//
//  ProjectRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ProjectRowView: View {
	/// Project information item
    let project: RecentProject
	
	/// Is `True` when row is focus
	let isSelected: Bool
	
	/// Func when select row
	var onSelect: (_ isDirectly: Bool) -> Void
	
	/// Func when is clicked remove row on list
    var onRemove: () -> Void
	
	/// Func when is cliked delete project
	var onDelete: () -> Void

    var body: some View {
		
		ZStack {
			Button(action: { onSelect(false) }) {
				HStack(spacing: 10) {
					
					Image(
						nsImage: IconCache.shared.icon(
							for: URL(fileURLWithPath: project.path)
						)
					)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 32, height: 32)
					
					VStack(alignment: .leading, spacing: 2) {
						Text(project.name)
							.font(.headline)
							.foregroundStyle(.primary)
						
						Text(project.path)
							.font(.caption)
							.foregroundStyle(.secondary)
							.lineLimit(1)
							.truncationMode(.middle)
						
					}
					
					Spacer()
					
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.contentShape(Rectangle())
				.onTapGesture(count: 2) { onSelect(true) }
				.contextMenu(menuItems: contextMenuContent)
				
			}
			.buttonStyle(RowButtonStyle(
				scaling		: false,
				cornerRadius: 17,
				isFocused   : isSelected
			))
			
			// Button for open directly the project
			Button("", action: { onSelect(true) })
				.buttonStyle(.plain)
				.keyboardShortcut(.return, modifiers: [])
		}
    }
	
	// MARK: - Handlers
	
	@ViewBuilder
	private func contextMenuContent() -> some View {
		
		Button {
			let url = URL(fileURLWithPath: project.path)
			NSWorkspace.shared.activateFileViewerSelecting([url])
			
		} label: {
			Label("Show in Finder", systemImage: "finder")
		}
		
		Divider()
		
		Button {
			 onSelect(true) // Open project
			
		} label: {
			Label("Open Project", systemImage: "macwindow.badge.plus")
		}
		
		Button {
			onRemove() // Remove element on list
			
		} label: {
			Label("Remove on List", systemImage: "text.badge.minus")
		}
		
		Divider()
		
		Button {
			onDelete() // Delete project
			
		} label: {
			Label("Delete Project", systemImage: "trash.fill")
		}
	
	}
}

