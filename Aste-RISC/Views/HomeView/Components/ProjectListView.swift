//
//  ProjectListView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

/// Rapresenting list with recent projects button
struct ProjectListView: View {
	
	/// Navigation to principal tabs on IDE
	@EnvironmentObject
	private var navigationViewModel: NavigationViewModel
	
	/// Manage the focus state on home screen
	@FocusState
	private var isFocused: Bool
	
	/// This variable is used for set the focus when
	/// the windows is rendered
	@State
	private var isReady: Bool = false
	
	/// Get the IDE global settings
	@State
	var globalSetting: GlobalSettings?
	
	/// Contains index of the row focused on list
	@State
	private var selectedRow: UInt32 = 0
	
	/// Settings manager, this save or load file settings
	private let settingsManager: SettingsManager = SettingsManager()
	
	/// Set the settings loaded, used for not read the memory
	/// all time
	private static var cachedValue: GlobalSettings?
   
    var body: some View {
		// Get the array recent projects
		let arrayRecentProject = globalSetting?.recentsProjects ?? []
        
        ScrollView {
            
            LazyVStack(spacing: 10) {
				ForEach(
					(globalSetting?.recentsProjects ?? []).enumerated(),
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
		.onKeyPress { pressed in
			handlerArrowPressed(
				pressed,
				size: arrayRecentProject.count
			)
		}
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
			secondaryNavigation: isDirectly ?
									.openDirectlyProject : .openProject
		)
	}
	
	/// Handle for remove recent project
	private func handleRemoveProjectOnList(_ project: RecentProject) {
		guard let index = self.globalSetting!.recentsProjects.firstIndex(
			where: { $0.id == project.id }
			
		) else { return }
		
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
	
	/// Change focus row on bassed in click up or down row
	private func handlerArrowPressed(
		_ 	 pressed  : KeyPress,
		size arraySize: Int
	) -> KeyPress.Result {
		
		switch pressed.key {
			case .upArrow:
				if self.selectedRow > 0 {
					self.selectedRow -= 1
				}
									
				return .handled
				
			case .downArrow:
				if self.selectedRow < arraySize - 1 {
					self.selectedRow += 1
				}
									
				return.handled
			
			default:
				return .ignored
		}
	}
	
	/// When appear load the settings and set the
	/// focus on window
	private func handlerOnAppear() {
		
		if Self.cachedValue == nil {
			self.globalSetting = self.settingsManager.load(
				file: "global_settings.json",
				GlobalSettings.self
			)
			
			Self.cachedValue = self.globalSetting
			
		} else { self.globalSetting = Self.cachedValue }
		
		if !self.isFocused {
			Task { @MainActor in
				self.isReady   = true
				self.isFocused = true
			}
		}
	}
}
