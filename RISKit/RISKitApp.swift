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
    
    var body: some Scene {
        WindowGroup(id: "home") {
            ContentHomeView()
                .environmentObject(self.appState)
        }
        .windowStyle(.hiddenTitleBar)
        
        WindowGroup(id: "editor") {
            BodyEditorViem()
                .environmentObject(self.appState)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
