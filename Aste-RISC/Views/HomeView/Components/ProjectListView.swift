//
//  ProjectListView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

/// Rapresenting list with recent projects button
struct ProjectListView: View {
	
	/// Navigation to principal tabs on IDE
	@EnvironmentObject
	private var navigationViewModel: NavigationViewModel
	
	@State
	var globalSetting: GlobalSettings?
	
	private let settingsManager: SettingsManager = SettingsManager()
   
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 10) {
				ForEach(globalSetting?.recentsProjects ?? []) { project in
                    ProjectRowView(
                        project : project,
						onSelect: { isDirectly in
							handleProjectSelection(
								project,
								isDirectly: isDirectly
							)
						},
                        onDelete: { handleProjectDeletion(project)  }
                    )
                    .id(project)
                }
            }
        }
        .scrollContentBackground(.hidden)
		.onAppear {
			self.globalSetting = self.settingsManager.load(
				file: "global_settings.json",
				GlobalSettings.self
			)
		}
    }
	
	// MARK: - Handlers
	
	/// Handle for open project and change view
	private func handleProjectSelection(
		_ project : RecentProject,
		isDirectly: Bool = false
	) {
		
		self.navigationViewModel.setProjectInformation(
			url : project.path,
			name: project.name
		)
		
		self.navigationViewModel.setSecondaryNavigation(
			secondaryNavigation: isDirectly ? .openDirectlyProject : .openProject
		)
	}
	
	/// Handle for remove recent project
	private func handleProjectDeletion(_ project: RecentProject) {
		guard let index = self.globalSetting!.recentsProjects.firstIndex(
			where: { $0.id == project.id }
			
		) else {
			return
		}
		
		withAnimation(.easeInOut(duration: 0.3)) {
			self.globalSetting!.removeProject(at: IndexSet(integer: index))
			self.settingsManager.save(self.globalSetting!)
		}
	}
}
