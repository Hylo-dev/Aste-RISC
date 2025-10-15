//
//  ContentView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

struct ContentHomeView: View {
    @EnvironmentObject private var appState: AppState
    
    /// Enviroment call for open new window
    @Environment(\.openWindow) private var openWindow
    
    /// Enviroment call for close the current window
    @Environment(\.dismiss) private var dismiss
    
    
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
    
    var body: some View {
        let navigationState = appState.navigationState
        
        switch navigationState.navigationItem.principalNavigation {
        case .HOME:
            HomeView()
            .sheet(isPresented: isCreateProjectPresented) {
                CreationProjectView(navigationState: navigationState)
                    .frame(width: 600, height: 400)
            }
            .alert(
                "Open Project '\(navigationState.navigationItem.selectedProjectName)'",
                isPresented: isOpenProjectAlertPresented,
                actions: {
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
                            appState.recentProjectsStore.addProject(name: name, path: path)
                            
                            navigationState.saveCurrentProjectState(path: path)
                        }
                        
                        Task { @MainActor in
                            openWindow(id: "editor")
                            dismiss()
                        }

                    }
                    .buttonStyle(.glass)

                }
            )
        }
    }
}

#Preview {
    ContentHomeView()
}
