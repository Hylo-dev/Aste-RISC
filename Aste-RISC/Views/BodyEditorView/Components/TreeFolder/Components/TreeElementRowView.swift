//
//  DirectoryRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct TreeElementRowView: View {
    @ObservedObject var node: FileNode
    
    var fileOpen  : URL?
    var level     : Int
    var onOpenFile: ((URL) -> Void)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if node.isDirectory {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        node.isExpanded.toggle()
                        if node.isExpanded { node.loadChildrenPreservingState(forceReload: false) }
                        
                    }
                    
                } else { onOpenFile(node.url) }
                
            }) { bodyButtonElement } // Body element
            .buttonStyle(.plain)
            .background(
                fileOpen == node.url ? Color.secondary.opacity(0.1) : Color.clear, in: .rect(cornerRadius: 12)
            )
            
            // Show element child
            if node.isDirectory && node.isExpanded {
                ForEach(node.children) { child in
                    TreeElementRowView(node: child, fileOpen: fileOpen, level: level + 1, onOpenFile: onOpenFile)
                }
            }
        }
    }
    
    private var bodyButtonElement: some View {
        return HStack(spacing: 6) {
            Color.clear.frame(width: CGFloat(level) * 14, height: 1)

            isDirectoryIcon

            Image(nsImage: IconCache.shared.icon(for: node.url))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)

            Text(node.name.isEmpty ? node.url.path : node.name)
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
            
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    private var isDirectoryIcon: some View {
        return Group {
            if node.isDirectory {
                Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                    .frame(width: 12, height: 12)
                    .imageScale(.small)
                
            } else {
                Color.clear.frame(width: 12, height: 12)
                
            }
        }
    }
}
