//
//  ToolbarStatusView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarStatusView: View {
    @EnvironmentObject private var appState: AppState
    
    @Binding var selectedFile: URL?
    @Binding var editorStatus: EditorStatus
    
    var body: some View {
        
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "desktopcomputer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(appState.navigationState.navigationItem.selectedProjectName)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .layoutPriority(1)
                
                if selectedFile != nil {
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Text(selectedFile!.lastPathComponent)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .layoutPriority(1)
                    
                }
                
            }
            .layoutPriority(1)
            
            Spacer()
            
            let projectName = appState.navigationState.navigationItem.selectedProjectName
            switch editorStatus {
                case .readyToBuild:
                    Text("\(projectName) is ready to build")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .building:
                    Text("\(projectName) is building")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .build:
                    Text("\(projectName) is build")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .running:
                    Text("\(projectName) is running")
                    .font(.subheadline)
                    .fontWeight(.light)
                
                case .stopped:
                    Text("Finished running \(projectName)")
                    .font(.subheadline)
                    .fontWeight(.light)
                    
            }
        }
        .frame(minWidth: 200, idealWidth: 500)
        .padding(12)
        .glassEffect()
    }
}
