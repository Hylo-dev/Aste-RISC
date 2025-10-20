//
//  TreeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryTreeView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    @StateObject       private var rootNode           : FileNode
                       private var onOpenFile         : ((URL) -> Void)? = nil
    
    init(
        rootURL       : URL,
        onOpenFile    : ((URL) -> Void)? = nil
    
    ) {
        self._rootNode  = StateObject(wrappedValue: FileNode(url: rootURL))
        self.onOpenFile = onOpenFile
        
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                DirectoryRow(
                    node: rootNode,
                    fileOpen: self.bodyEditorViewModel.currentFileSelected,
                    level: 0,
                    onOpenFile: onOpenFile
                )
                
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
