//
//  RigthMenuView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//



import SwiftUI

/// Contain each project recent open on IDE
struct ProjectRecentView: View {
    
    /// Navigation to principal tabs on IDE
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    
    @State private var globalSetting: GlobalSettings? = nil
    
    private let settingsManager: SettingsManager = SettingsManager()
    
    var body: some View {
        
        // List rapresenting recent projects
        ProjectListView(
            projects: globalSetting?.recentsProjects ?? [],
            onSelect: handleProjectSelection,
            onDelete: handleProjectDeletion,
            
        )
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .trailing)
        .onAppear {
            self.globalSetting = self.settingsManager.load(
                file: "global_settings.json",
                GlobalSettings.self
            )
        }
        
    }
    
    /// Handle for open project and change view
    private func handleProjectSelection(_ project: RecentProject) {
		self.navigationViewModel.setProjectInformation(url: project.path, name: project.name)
		self.navigationViewModel.setSecondaryNavigation(secondaryNavigation: .openProject)
    }
    
    /// Handle for remove recent project
    private func handleProjectDeletion(_ project: RecentProject) {
        guard let index = self.globalSetting!.recentsProjects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            self.globalSetting?.removeProject(at: IndexSet(integer: index))
            self.settingsManager.save(self.globalSetting!)
        }
    }
}
