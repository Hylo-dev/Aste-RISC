//
//  SettingsView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedSection: SettingsSection? = SettingsSection.allCases.first
    
    var body: some View {
        TabView(selection: $selectedSection) {
            ForEach(SettingsSection.allCases, id: \.id) { section in
                
                switch section {
                case .general:
                    GeneralSettingView()
                        .tabItem { Label(section.rawValue, systemImage: section.systemImageName) }
                        .tag(section.id)
                }
                
                    
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
