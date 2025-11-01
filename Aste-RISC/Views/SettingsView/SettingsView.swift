//
//  SettingsView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedSection: SettingsSection = SettingsSection.allCases.first!
    
    private var settingsManager: SettingsManager = SettingsManager()
    
    var body: some View {
        TabView(selection: $selectedSection) {
            ForEach(SettingsSection.allCases) { section in
            
                getScreenSetting(section)
                    .tabItem { Label(section.rawValue, systemImage: section.systemImageName) }
                    .tag(section)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) { Text(selectedSection.rawValue).font(.title2) }
            .sharedBackgroundVisibility(.hidden)
        }
        .tabViewStyle(.sidebarAdaptable)
    }
    
    @ViewBuilder
    private func getScreenSetting(_ section: SettingsSection) -> some View {
        
        switch section {
        case .general:
            GeneralSettingView()
            
        case .editor:
            EditorSettingView(settingsManager: settingsManager)
            
        case .editing:
            EditingSettingView()
            
        case .theme:
            ThemeSettingView()
        }
    }
}
