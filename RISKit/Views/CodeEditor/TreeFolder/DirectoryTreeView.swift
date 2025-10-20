//
//  TreeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryTreeView: View {
    @StateObject private var rootNode: FileNode
    
    @Binding var currentFile: URL?
             var onOpenFile : ((URL) -> Void)? = nil
    
    init(
        rootURL       : URL,
        currentFile   : Binding<URL?>,
        onOpenFile    : ((URL) -> Void)? = nil
    
    ) {
        _rootNode = StateObject(wrappedValue: FileNode(url: rootURL))
                
        self._currentFile = currentFile
        self.onOpenFile = onOpenFile
        
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                DirectoryRow(node: rootNode, currentFile: $currentFile, level: 0, onOpenFile: onOpenFile)
                
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            
        }
        .frame(minWidth: 220)
        .onAppear {
            refresh()
            
        }
    }
    
    private func refresh() {
        guard rootNode.isDirectory else { return }

        rootNode.loadChildrenPreservingState(async: true, forceReload: true)

        rootNode.isExpanded = true
    }


}
