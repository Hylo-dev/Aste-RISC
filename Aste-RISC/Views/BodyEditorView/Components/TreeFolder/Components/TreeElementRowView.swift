//
//  DirectoryRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct TreeElementRowView: View {
    @ObservedObject var node: FileNode
    
	@Binding var isSelected: Int
	
    var fileOpen  : URL?
    var level     : Int
    var onOpenFile: ((URL) -> Void)

    var body: some View {
		
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
				if !self.node.isDirectory {
					onOpenFile(node.url)
				}
				
				self.isSelected = level
                
            }) { bodyButtonElement } // Body element
            .buttonStyle(.plain)
			.background(
				RoundedRectangle(cornerRadius: 8)
					.fill(self.isSelected == level ? Color.accentColor : .clear)
			)
			.contextMenu {
				Button {
					print("Azione 'Modifica' selezionata")
					
				} label: {
					Label("Modifica", systemImage: "pencil")
				}
			}
			.onChange(of: self.fileOpen) { _, newValue in
				print("file open: \(newValue?.absoluteString ?? "nil")")
				print("file node: \(self.node.url.absoluteString)")
				
				if newValue == self.node.url { self.isSelected = level }
			}
            
            // Show element child
			if node.isDirectory {
				
				VStack(spacing: 0) {
					
					if node.isExpanded {
						ForEach(node.children) { child in
							TreeElementRowView(
								node: child,
								isSelected: $isSelected,
								fileOpen: fileOpen,
								level: level + 1,
								onOpenFile: onOpenFile
							)
							.transition(.move(edge: .top).combined(with: .opacity))
						}
					}
				}
				
			}

        }
		.clipped()
    }
    
    private var bodyButtonElement: some View {
        return HStack(spacing: 7) {
			Color.clear.frame(width: CGFloat(level) * CGFloat(self.node.isDirectory ? 20 : 12), height: 1)

			HStack(spacing: 5) {
				isDirectoryIcon

				Image(nsImage: IconCache.shared.icon(for: node.url))
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 17, height: 17)
			}

            Text(node.name.isEmpty ? node.url.path : node.name)
				.font(.body)
                .lineLimit(1)
            
			Spacer(minLength: 0)
            
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    private var isDirectoryIcon: some View {
        return Group {
            if node.isDirectory {
                Image(systemName: "chevron.right") // node.isExpanded ? "chevron.down" : "chevron.right"
					.font(.caption)
					.fontWeight(.bold)
					.foregroundStyle(.secondary)
					.padding(3)
					.contentShape(Rectangle())
					.rotationEffect(Angle(degrees:  self.node.isExpanded ? 90 : 0))
					.onTapGesture {
						if node.isDirectory {
							withAnimation(.spring()) {
								node.isExpanded.toggle()
								if node.isExpanded { node.loadChildrenPreservingState(forceReload: false) }
								
							}
						}
					}
                
            } else {
                Color.clear.frame(width: 12, height: 12)
                
            }
        }
    }
}
