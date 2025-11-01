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
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    
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
            
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: "document.badge.plus")
                        .frame(width: 38, height: 38)
                    
                }
                
                VStack(alignment: .leading) {
                    Text("Create new project")
                        .font(.title)
                        .bold()
                    
                    Text("Create a new assembly project")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Contain information modificable
            VStack(
                alignment: .leading,
                spacing: 17
                
            ) {
                VStack(alignment: .leading) {
                    Text("Project name:")
                        .font(.headline)
                    
                    TextField("Project name", text: $viewModel.nameProject)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("Location:")
                        .font(.headline)
                    
                    TextField("Location", text: $viewModel.locationProject)
                        .textFieldStyle(.roundedBorder)
                    
                }
                
            }
            .padding(.vertical)
            
            Spacer()
            
            // Row for back and continue buttons.
            HStack {
				Button("Back") { self.navigationViewModel.cleanSecondaryNavigation() }
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
				self.navigationViewModel.setProjectInformation(
                    url: path,
                    name: viewModel.nameProject
                )
                
				self.navigationViewModel.setSecondaryNavigation(secondaryNavigation: .openProject)
            }
            
            creating = false
        }
    }
}
