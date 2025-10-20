//
//  DirectoryRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryRow: View {
    @ObservedObject var node: FileNode
    
    var fileOpen  : URL?
    var level     : Int
    var onOpenFile: ((URL) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if node.isDirectory {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        node.isExpanded.toggle()
                        
                        if node.isExpanded { node.loadChildrenPreservingState(forceReload: false) }
                        
                    }
                    
                } else {
                    onOpenFile?(node.url)
                    
                }
                
            }) {
                HStack(spacing: 6) {
                    Color.clear.frame(width: CGFloat(level) * 14, height: 1)

                    if node.isDirectory {
                        Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                            .frame(width: 12, height: 12)
                            .imageScale(.small)
                        
                    } else {
                        Color.clear.frame(width: 12, height: 12)
                        
                    }

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
            .buttonStyle(.plain)
            .background(fileOpen == node.url ? Color.secondary.opacity(0.1) : Color.clear, in: .rect(cornerRadius: 12))
            
            if node.isDirectory && node.isExpanded {
                ForEach(node.children) { child in
                    DirectoryRow(node: child, fileOpen: fileOpen, level: level + 1, onOpenFile: onOpenFile)
                }
            }
        }
    }
}
