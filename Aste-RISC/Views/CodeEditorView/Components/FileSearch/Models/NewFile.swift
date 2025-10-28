//
//  CreationFileItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/08/25.
//

import Foundation

struct NewFile: Identifiable {
    let id = UUID()
    
    let name: String
    let lang: FileType
}
