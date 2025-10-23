//
//  SettingsSection.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

enum SettingsSection: String, Identifiable, CaseIterable {
    case general = "General"
    case editor  = "Editor"
    case editing = "Editing"
    case theme   = "Themes"

    var id: String { rawValue }
    
    var systemImageName: String {
        switch self {
        case .general: "gearshape"
        case .editor:  "square.and.pencil"
        case .editing: "macwindow"
        case .theme:   "paintbrush"
        }
    }
}
