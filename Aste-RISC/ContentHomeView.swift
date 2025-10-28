//
//  ContentView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

struct ContentHomeView: View {
    @EnvironmentObject private var appState: AppState
    
    @Environment(\.openWindow) private var openWindow /// Enviroment call for open new window
    @Environment(\.dismiss)    private var dismiss    /// Enviroment call for close the current window
    
    /// Binding state, this show the creation project
    private var isCreateProjectPresented: Binding<Bool> {
        Binding(
            get: { appState.navigationState.navigationItem.secondaryNavigation == .CREATE_PROJECT },
            set: { newValue in if !newValue { appState.navigationState.cleanSecondaryNavigation() } }
        )
    }
    
    /// Binding state, this show alert to change view
    private var isOpenProjectAlertPresented: Binding<Bool> {
        Binding(
            get: { appState.navigationState.navigationItem.secondaryNavigation == .CONTROL_OPEN_PROJECT },
            set: { newValue in if !newValue { appState.navigationState.cleanSecondaryNavigation() } }
        )
    }
    
    private let settingsManager: SettingsManager = SettingsManager()
    
    var body: some View {
        let navigationState = appState.navigationState
        
        switch navigationState.navigationItem.principalNavigation {
        case .home:
            HomeView()
                .onAppear {
                    if !appState.isSettingsFolderExist() {
                        navigationState.setPrincipalNavigation(principalNavigation: .welcome)
                    }
                }
                .sheet(isPresented: isCreateProjectPresented) {
                    CreationProjectView()
                        .frame(width: 600, height: 400)
                    
                }
                .alert(
                    "Open Project '\(navigationState.navigationItem.selectedProjectName)'",
                    isPresented: isOpenProjectAlertPresented,
                    actions: alertContent
                )
            
        case .welcome:
            WelcomeView()
        }
    }
    
    @ViewBuilder
    private func alertContent() -> some View {
        let navigationState = appState.navigationState
        
        Button("No", role: .cancel) {
            navigationState.cleanProjectInformation()
            navigationState.cleanSecondaryNavigation()
        }
        .buttonStyle(.glass)
        
        Button("Yes") {
            let path = navigationState.navigationItem.selectedProjectPath
            let name = navigationState.navigationItem.selectedProjectName

            withTransaction(Transaction(animation: nil)) {
                appState.setEditorProjectPath(path)
                
                var oldSettings = settingsManager.load(file: "global_settings.json",GlobalSettings.self)
                
                if oldSettings != nil {
                    oldSettings?.addRecentProject(name: name, path: path)
                    
                    settingsManager.save(oldSettings!)
                    
                    //appState.recentProjectsStore.addProject(name: name, path: path)
                    
                    navigationState.saveCurrentProjectState(path: path)
                }                
            }
            
            Task { @MainActor in
                openWindow(id: "editor")
                dismiss()
            }

        }
        .buttonStyle(.glass)
    }
}

#Preview {
    ContentHomeView()
}
