//
//  RISKitApp.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI

@main
struct RISKitApp: App {
    @StateObject private var appState = AppState()
    
    @Environment(\.openWindow) private var openWindow
	@Environment(\.dismiss)    private var dismiss
    
    var body: some Scene {
        // Home screen
        WindowGroup(id: "home") {
            ContentHomeView().environmentObject(self.appState)
        }
        .windowStyle(.hiddenTitleBar)
        
        // Editor screen
        WindowGroup(id: "editor") {
			EditorWindowWrapper().environmentObject(self.appState)
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

struct EditorWindowWrapper: View {
	@EnvironmentObject var appState: AppState
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismiss) private var dismiss
	
	@State private var hasHandledInvalidPath = false
	
	var body: some View {
		let path = appState.navigationState.navigationItem.selectedProjectPath
		
		if path.isEmpty || path == "/" {
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
			BodyEditorView()
		}
	}
}
