//
//  RISKitApp.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

@main
struct RISKitApp: App {
    @Environment(\.openWindow) private var openWindow
	@Environment(\.dismiss)    private var dismiss
	
	@StateObject private var navigationViewModel = NavigationViewModel()
    
    var body: some Scene {
        // Home screen
        WindowGroup(id: "home") {
            ContentHomeView()
				.environmentObject(self.navigationViewModel)
        }
        .windowStyle(.hiddenTitleBar)
        
        // Editor screen
        WindowGroup(id: "editor") {
			EditorWindowWrapper(
				selectedProjectPath: self.navigationViewModel.selectedProjectPath,
				selectedProjectName: self.navigationViewModel.selectedProjectName
			)
			.onDisappear {
				withTransaction(Transaction(animation: nil)) {
					self.navigationViewModel.saveCurrentProjectState(path: "")
				}
					
				Task { openWindow(id: "home") }
			}
        }
        .windowStyle(.hiddenTitleBar)
        
        // Setting Window
        WindowGroup(id: "preferences") {
            SettingsView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button {
                    openWindow(id: "preferences")
                    
                } label: {
                    Label("Settings…", systemImage: "gearshape")
                    
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
}

private struct EditorWindowWrapper: View {
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismiss)    private var dismiss
	
	@State private var hasHandledInvalidPath = false
	let selectedProjectPath: String
	let selectedProjectName: String
	
	var body: some View {
		
		if selectedProjectPath.isEmpty || selectedProjectPath == "/" {
			Color.clear
				.onAppear {
					guard !hasHandledInvalidPath else { return }
					hasHandledInvalidPath = true
					
					dismiss()
					Task {
						try? await Task.sleep(nanoseconds: 100_000_000)
						openWindow(id: "home")
					}
				}
			
		} else {
			BodyEditorView(
				selectedProjectPath: self.selectedProjectPath,
				selectedProjectName: self.selectedProjectName
			)
		}
	}
}
