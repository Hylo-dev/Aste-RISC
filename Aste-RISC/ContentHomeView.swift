//
//  ContentView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

struct ContentHomeView: View {
	@EnvironmentObject
	private var navigationViewModel: NavigationViewModel
	
	/// Enviroment call for open new window
    @Environment(\.openWindow)
	private var openWindow
	
	/// Enviroment call for close the current window
    @Environment(\.dismiss)
	private var dismiss
	
    /// Binding state, this show the creation project
    private var isCreateProjectPresented: Binding<Bool> {
        Binding(
			get: {
				self.navigationViewModel.secondaryNavigation == .createProject
			},
			set: { newValue in
				if !newValue {
					self.navigationViewModel.cleanSecondaryNavigation()
				}
			}
        )
    }
    
    /// Binding state, this show alert to change view
    private var isOpenProjectAlertPresented: Binding<Bool> {
        Binding(
			get: {
				self.navigationViewModel.secondaryNavigation == .openProject
			},
			set: { newValue in
				if !newValue {
					self.navigationViewModel.cleanSecondaryNavigation()
				}
			}
        )
    }
    
    private let settingsManager: SettingsManager = SettingsManager()
    
    var body: some View {
        
        switch self.navigationViewModel.principalNavigation {
			case .home:
				HomeView()
					.onAppear {
						if !self.navigationViewModel.isSettingsFolderExist() {
							self.navigationViewModel.setPrincipalNavigation(
								principalNavigation: .welcome
							)
						}
					}
					.onChange(
						of: self.navigationViewModel.secondaryNavigation,
						handlerOnSecondaryNavigationChange
					)
					.sheet(isPresented: isCreateProjectPresented) {
						CreationProjectView()
							.frame(width: 600, height: 400)
						
					}
					.alert(
						"Open Project '\(self.navigationViewModel.selectedProjectName)'",
						isPresented: isOpenProjectAlertPresented,
						actions: alertContent
					)
				
			case .welcome:
				WelcomeView()
        }
    }
	
	// MARK: - Views
    
    @ViewBuilder
    private func alertContent() -> some View {
        Button("No", role: .cancel) {
			self.navigationViewModel.cleanProjectInformation()
			self.navigationViewModel.cleanSecondaryNavigation()
        }
        .buttonStyle(.glass)
        
        Button("Yes") {
            handlerOpenProject()
        }
        .buttonStyle(.glass)
    }
	
	// MARK: - Handlers
	
	private func handlerOnSecondaryNavigationChange(
		_ oldValue: SecondaryNavigationState?,
		_ newValue: SecondaryNavigationState?
	) {
		if newValue == .openDirectlyProject {
			handlerOpenProject()
		}
	}
	
	private func handlerOpenProject() {
		let path = self.navigationViewModel.selectedProjectPath
		let name = self.navigationViewModel.selectedProjectName

		withTransaction(Transaction(animation: nil)) {
			var oldSettings = settingsManager.load(file: "global_settings.json", GlobalSettings.self)
			
			if oldSettings != nil {
				oldSettings?.addRecentProject(name: name, path: path)
				oldSettings?.lastProjectOpened = path
				
				settingsManager.save(oldSettings!)
			}
		}
		
		Task { @MainActor in
			openWindow(id: "editor")
			dismiss()
		}
	}
}

#Preview {
    ContentHomeView()
}
