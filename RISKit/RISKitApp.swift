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
    
    var body: some Scene {
        // Home screen
        WindowGroup(id: "home") {
            ContentHomeView().environmentObject(self.appState)
        }
        .windowStyle(.hiddenTitleBar)
        
        // Editor screen
        WindowGroup(id: "editor") {
            BodyEditorView().environmentObject(self.appState)
        }
        .windowStyle(.hiddenTitleBar)
        
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
