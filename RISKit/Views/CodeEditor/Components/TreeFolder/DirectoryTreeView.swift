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
                       private var onOpenFile         : ((URL) -> Void)
    
    init(
        rootURL       : URL,
        onOpenFile    : @escaping ((URL) -> Void)
    ) {
        self._rootNode  = StateObject(wrappedValue: FileNode(url: rootURL))
        self.onOpenFile = onOpenFile
        
    }

    var body: some View {
        ScrollView { treeProject } // Show all projects on tree
        .frame(minWidth: 220)
        .onAppear {
            guard rootNode.isDirectory else { return }

            rootNode.loadChildrenPreservingState(forceReload: true)
            rootNode.isExpanded = true
            
        }
    }
    
    private var treeProject: some View {
        return LazyVStack(alignment: .leading, spacing: 0) {
            TreeElementRowView(
                node: rootNode,
                fileOpen: self.bodyEditorViewModel.currentFileSelected,
                level: 0,
                onOpenFile: onOpenFile
            )
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
