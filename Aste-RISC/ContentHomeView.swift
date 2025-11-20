//
//  ContentView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

struct ContentHomeView: View {
	@EnvironmentObject
	private var viewModel: NavigationViewModel
	
	/// Enviroment call for open new window
    @Environment(\.openWindow)
	private var openWindow
	
	/// Enviroment call for close the current window
    @Environment(\.dismiss)
	private var dismiss
    
    private let settingsManager: SettingsManager = SettingsManager()
    
    var body: some View {
        
        switch self.viewModel.principalNavigation {
			case .home:
				HomeView()
					.onAppear {
						if !self.viewModel.isSettingsFolderExist() {
							self.viewModel.setPrincipalNavigation(
								principalNavigation: .welcome
							)
						}
					}
					.onChange(
						of: self.viewModel.secondaryNavigation,
						handlerOnSecondaryNavigationChange
					)
					.sheet(
						isPresented: self.viewModel.isCreateProjectPresented
					) {
						CreationProjectView()
							.frame(width: 600, height: 400)
						
					}
					.alert(
						"Open Project '\(self.viewModel.selectedProjectName)'",
						isPresented: self.viewModel.isOpenProjectAlertPresented,
						actions	   : alertContent
					)
				
			case .welcome:
				WelcomeView()
        }
    }
	
	// MARK: - Views
    
    @ViewBuilder
    private func alertContent() -> some View {
        Button("No", role: .cancel) {
			self.viewModel.cleanProjectInformation()
			self.viewModel.cleanSecondaryNavigation()
        }
        .buttonStyle(.glass)
        
        Button("Yes") {
            handlerOpenProject()
        }
        .buttonStyle(.glass)
    }
	
	// MARK: - Handlers
	
	/// If secondary navigation is changed then
	/// open directly project
	private func handlerOnSecondaryNavigationChange(
		_ oldValue: SecondaryNavigationState?,
		_ newValue: SecondaryNavigationState?
	) {
		if newValue == .openDirectlyProject {
			handlerOpenProject()
		}
	}
	
	/// Function for open project
	private func handlerOpenProject() {
		let path = self.viewModel.selectedProjectPath
		let name = self.viewModel.selectedProjectName

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
