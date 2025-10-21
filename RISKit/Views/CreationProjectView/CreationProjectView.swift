//
//  CreationProjectView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

/// Principal screen for creation projects, select type project
struct CreationProjectView: View {
    
    /// Nvigation and current state app
    @EnvironmentObject private var appState: AppState
    
    /// View model for manage creation project
    @StateObject private var viewModel = CreationProjectViewModel()

    /// State creation project
    @State private var creating: Bool = false
    
    /// URL project create
    @State private var urlProject: URL? = nil
    
    @State private var errorMessage: String? = nil
    
    var body: some View {
        
        // Prinpal column, contain information modifiables project
        VStack(alignment: .leading) {
            
            Text("Set your new project")
                .font(.title2).bold()
            
            // Contain information modificable
            VStack(alignment: .leading, spacing: 10) {
                Text("Project name:")
                TextField("Project name", text: $viewModel.nameProject)
                    .textFieldStyle(.roundedBorder)
                
                Text("Location:")
                TextField("Location", text: $viewModel.locationProject)
                    .textFieldStyle(.roundedBorder)
                
            }
            .padding()
            
            Spacer()
            
            // Row for back and continue buttons.
            HStack {
                Button("Back") { appState.navigationState.cleanSecondaryNavigation() }
                    .buttonStyle(.glass)
                
                Spacer()
                
                Button("Create") { createProjectHandle() }
                    .buttonStyle(.glassProminent)
                    .disabled(creating || viewModel.nameProject.isEmpty || viewModel.locationProject.isEmpty)
            }
        }
        .padding()
        .alert(
            "Error to create project",
            isPresented: Binding( get: { errorMessage != nil }, set: { _ in errorMessage = nil } )
        ) {
            Button("OK", role: .cancel) { }
            
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func createProjectHandle() {
        creating = true
        
        Task { @MainActor in
            do {
                urlProject = try await viewModel.createProject()
                
            } catch {
                urlProject = nil
                errorMessage = error.localizedDescription
                
            }
            
            if let path = urlProject?.path, !path.isEmpty {
                appState.navigationState.setProjectInformation(
                    url: path,
                    name: viewModel.nameProject
                )
                
                appState.navigationState.setSecondaryNavigation(currentSecondaryNavigation: .CONTROL_OPEN_PROJECT)
                
            }
            
            creating = false
        }
    }
}
