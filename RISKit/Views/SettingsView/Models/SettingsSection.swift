//
//  SettingsSection.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

enum SettingsSection: String, Identifiable, CaseIterable {
    case general = "Generale"

    var id: String { rawValue }
    
    var systemImageName: String {
        switch self {
        case .general: "gearshape"
        }
    }
}
