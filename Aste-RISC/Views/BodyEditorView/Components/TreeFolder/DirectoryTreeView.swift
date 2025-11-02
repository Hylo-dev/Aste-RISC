//
//  TreeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryTreeView: View {
    @StateObject private var rootNode: FileNode
                 
	@Binding private var currentFileSelected: URL?
	private var onOpenFile: ((URL) -> Void)
    
    init(
        rootURL       : URL,
		fileOpen	  : Binding<URL?>,
        onOpenFile    : @escaping ((URL) -> Void)
    ) {
        self._rootNode  		  = StateObject(wrappedValue: FileNode(url: rootURL))
		self._currentFileSelected = fileOpen
        self.onOpenFile			  = onOpenFile
    }

    var body: some View {
        ScrollView { treeView } // Show all projects on tree
        .frame(minWidth: 220)
        .onAppear {
            guard rootNode.isDirectory else { return }

            rootNode.loadChildrenPreservingState(forceReload: true)
            rootNode.isExpanded = true
        }
		.onChange(of: currentFileSelected) { _, newURL in
			guard let urlToOpen = newURL else { return }
			_ = rootNode.expandTo(url: urlToOpen)
		}
    }
    
    private var treeView: some View {
        return LazyVStack(alignment: .leading, spacing: 0) {
            TreeElementRowView(
                node	  : rootNode,
				fileOpen  : self.currentFileSelected,
                level	  : 0,
                onOpenFile: onOpenFile
            )
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
