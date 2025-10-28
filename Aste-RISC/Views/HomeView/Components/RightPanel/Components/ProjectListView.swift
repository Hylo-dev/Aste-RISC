//
//  ProjectListView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

/// Rapresenting list with recent projects button
struct ProjectListView: View {
    let projects: [RecentProject]
    let onSelect: (RecentProject) -> Void
    let onDelete: (RecentProject) -> Void
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 10) {
                ForEach(projects, id: \.id) { project in
                    ProjectRowView(
                        project : project,
                        onSelect: { onSelect(project) },
                        onDelete: { onDelete(project) }
                        
                    )
                    .id(project.id)
                    
                }
            }
            
        }
        .scrollContentBackground(.hidden)
    }
}
