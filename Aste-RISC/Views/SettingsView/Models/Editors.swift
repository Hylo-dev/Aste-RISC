//
//  Editors.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/10/25.
//

enum Editors: String, Identifiable, CaseIterable, Codable {
    case native = "RISKit Native"
    case helix  = "Helix"
    case vim    = "Vim"
    case nvim   = "NeoVim"
    
    var id: String { rawValue }
}
