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
	
	/// Func when select row
    var onSelect: () -> Void
	
	// Func when click delete row
    var onDelete: () -> Void

    var body: some View {
        
        Button(action: onSelect) {
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
			.contextMenu {
				// Opzione 1
				Button {
					onDelete()
				} label: {
					Label("Delete", systemImage: "trash.fill")
				}
			}
        }
		.buttonStyle(RowButtonStyle(scaling: false))
    }
}

