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
    @EnvironmentObject
	private var navigationViewModel: NavigationViewModel
    
    /// View model for manage creation project
    @StateObject
	private var creationProjectViewModel = CreationProjectViewModel()
	
	@State
	private var errorMessage: String = ""
    
    var body: some View {
        
        // Principal column, contain information modifiables project
        VStack(
			alignment: .leading,
			spacing  : 27
		) {
            headerCreationWindow
            
            // Contain information modificable
            VStack(
                alignment: .leading,
                spacing  : 25
                
            ) {
                VStack(alignment: .leading) {
                    Text("Project name:")
						.font(.subheadline.uppercaseSmallCaps())
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
                    
                    TextField(
						"Name",
						text: self.$creationProjectViewModel.project.name
					)
					.font(.title3)
					.fontDesign(.rounded)
					.fontWeight(.medium)
                }
                
                VStack(alignment: .leading) {
                    Text("Project path:")
						.font(.subheadline.uppercaseSmallCaps())
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
                    
                    TextField(
						"Path",
						text: self.$creationProjectViewModel.project.path
					)
					.font(.title3)
					.fontDesign(.monospaced)
					.fontWeight(.medium)
					.foregroundStyle(.primary)
                    
                }
                
				Spacer()
				
				footerManageWindowState
            }
			.padding(.horizontal)
			.padding(.top)
			.padding(.bottom, 10)
			.background(.ultraThinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			
        }
        .padding()
        .alert(
            "Error to create project",
            isPresented: Binding(
				get: { self.errorMessage != "" },
				set: { _ in self.errorMessage = "" }
			)
			
        ) {
            Button("OK", role: .cancel) { }
            
        } message: { Text(errorMessage) }
    }
	
	// MARK: Views
	
	/// Set header for creation project window, this contains title,
	/// subtitle and icon for rapresent the creation of project
	private var headerCreationWindow: some View {
		HStack(spacing: 10) {
			ZStack {
				RoundedRectangle(cornerRadius: 10)
					.fill(.tint)
					.frame(
						width : 42,
						height: 42
					)
				
				Image(systemName: "document.badge.plus.fill")
					.frame(
						width : 42,
						height: 42
					)
			}
			
			VStack(alignment: .leading) {
				Text("Create new project")
					.font(.title)
					.bold()
					.fontDesign(.rounded)
				
				Text("Create a new assembly project")
					.font(.headline)
					.fontWeight(.light)
					.foregroundStyle(.secondary)
			}
		}
	}
	
	/// Contains button for close window or create the project
	private var footerManageWindowState: some View {
		
		// Row for back and continue buttons.
		HStack {
			let isDisable = self.creationProjectViewModel.creating ||
				self.creationProjectViewModel.project.name.isEmpty ||
				self.creationProjectViewModel.project.path.isEmpty
			
			Button("Back") {
				self.navigationViewModel.cleanSecondaryNavigation()
			}
			
			Spacer()
			
			Button("Create") { handleCreationProject() }
			.if(!isDisable, transform: { view in
				view.keyboardShortcut(.return, modifiers: [])
			})
			.buttonStyle(.glassProminent)
			.disabled(isDisable)
		}
	}
	
	
	// MARK: - Handle creation
	
	/// Call async function for create the new project folder
	/// and main template
	private func handleCreationProject() {
		Task {
			let result = await
							self.creationProjectViewModel.createProjectHandle()
			
			if let path = result.projectUrl?.path,
				  !path.isEmpty {
				
				self.navigationViewModel.setProjectInformation(
					url: path,
					name: self.creationProjectViewModel.project.name
				)
				
				self.navigationViewModel.setSecondaryNavigation(
					secondaryNavigation: .openProject
				)
				
			} else if let message = result.errorMessage {
				self.errorMessage = message
			}
		}
	}
	
}
