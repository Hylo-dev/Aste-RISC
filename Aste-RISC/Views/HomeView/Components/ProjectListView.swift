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
	
	@FocusState
	private var isFocused: Bool
	
	@State
	private var isReady: Bool = false
	
	@State
	var globalSetting: GlobalSettings?
	
	@State
	private var selectedRow: UInt32 = 0
	
	private let settingsManager: SettingsManager = SettingsManager()
   
    var body: some View {
		let arrayRecentProject = globalSetting?.recentsProjects ?? []
        
        ScrollView {
            
            LazyVStack(spacing: 10) {
				ForEach(
					arrayRecentProject.enumerated(),
					id: \.element.id
					
				) { index, project in
                    ProjectRowView(
                        project   : project,
						isSelected: index == self.selectedRow,
						onSelect  : { isDirectly in
							handleProjectSelection(
								project,
								isDirectly: isDirectly
							)
						},
                        onRemove: { handleRemoveProjectOnList(project) },
						onDelete: { handlerDeleteProject(project) }
                    )
                    .id(project)
                }
            }
        }
        .scrollContentBackground(.hidden)
		.focusable(isReady)
		.focusEffectDisabled()
		.focused($isFocused)
		.onAppear(perform: handlerOnAppear)
		.onKeyPress(action: handlerArrowPressed)
    }
	
	// MARK: - Handlers Project
	
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
	private func handleRemoveProjectOnList(_ project: RecentProject) {
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
	 
	/// Move to trash the project and remove reference on list
	private func handlerDeleteProject(_ project: RecentProject) {
		guard let index = self.globalSetting!.recentsProjects.firstIndex(
			where: { $0.id == project.id }
			
		) else { return }
		
		let fileManager = FileManager.default
		
		if fileManager.fileExists(atPath: project.path) {
			do {
				try fileManager.trashItem(
					at: URL(fileURLWithPath: project.path),
					resultingItemURL: nil
				)
				
			} catch {
				print(error.localizedDescription)
			}
		}
		
		withAnimation(.easeInOut(duration: 0.3)) {
			self.globalSetting!.removeProject(at: IndexSet(integer: index))
			self.settingsManager.save(self.globalSetting!)
		}
	}
	
	// MARK: - Handler View
	
	private func handlerArrowPressed(_ pressed: KeyPress) -> KeyPress.Result {
		let arrayRecentProject = globalSetting?.recentsProjects ?? []
		
		switch pressed.key {
			case .upArrow:
				if self.selectedRow > 0 {
					self.selectedRow -= 1
				}
									
				return .handled
				
			case .downArrow:
				if self.selectedRow < arrayRecentProject.count - 1 {
					self.selectedRow += 1
				}
									
				return.handled
			
			default:
				return .ignored
		}
	}
	
	private func handlerOnAppear() {
		self.globalSetting = self.settingsManager.load(
			file: "global_settings.json",
			GlobalSettings.self
		)
		
		Task { @MainActor in
			self.isReady   = true
			self.isFocused = true
		}
	}
}
