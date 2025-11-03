//
//  ToolbarStatusView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarStatusView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
	@Binding private var fileSelected: URL?
	
	let selectProjectName: String
	
	init(
		fileSelected	 : Binding<URL?>,
		selectProjectName: String
	) {
		self._fileSelected = fileSelected
		self.selectProjectName = selectProjectName
	}
    
    var body: some View {
        
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "desktopcomputer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(selectProjectName)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .layoutPriority(1)
                
				// self.bodyEditorViewModel.currentFileSelected
				if let fileOpen = self.fileSelected {
                
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Text(fileOpen.lastPathComponent)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .layoutPriority(1)
                    
                }
                
            }
            .layoutPriority(1)
            
            Spacer()
                        
            switch self.bodyEditorViewModel.editorState {
                case .readyToBuild:
                    Text("\(selectProjectName) is ready to build")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .building:
                    Text("\(selectProjectName) is building")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .build:
                    Text("\(selectProjectName) is build")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .running:
                    Text("\(selectProjectName) is running")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .stopped:
                    Text("Finished running \(selectProjectName)")
                    .font(.subheadline)
                    .fontWeight(.light)
            }
			
        }
        .frame(minWidth: 200, idealWidth: 500)
        .padding(12)
        .glassEffect()
    }
}
