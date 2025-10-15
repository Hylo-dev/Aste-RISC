//
//  RigthMenuView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//



import SwiftUI

/// Contain each project recent open on IDE
struct ProjectRecentView: View {
    
    /// Navigation app state
    @ObservedObject var navigationState: NavigationState
    
    /// Save and looad recent projects on JSON
    @ObservedObject var recentProjectsStore: RecentProjectsStore
    
    var body: some View {
        // List rapresenting recetprojects
        ProjectListView(
            projects: recentProjectsStore.projects,
            onSelect: handleProjectSelection,
            onDelete: handleProjectDeletion,
            
        )
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .trailing)
    }
        
    /// Handle for open project and change view
    private func handleProjectSelection(_ project: RecentProject) {
        navigationState.setProjectInformation(url: project.path, name: project.name)
        navigationState.setSecondaryNavigation(currentSecondaryNavigation: .CONTROL_OPEN_PROJECT)
    }
    
    /// Handle for remove recent project
    private func handleProjectDeletion(_ project: RecentProject) {
        guard let index = recentProjectsStore.projects.firstIndex(where: { $0.id == project.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            recentProjectsStore.removeProject(at: IndexSet(integer: index))
        }
    }
}
