//
//  NewProjectItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

import Foundation

struct NewProjectItem {
    var nameProject    : String = ""
    var locationProject: String = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("RISKitProjects", isDirectory: true).path
    
    var versionLanguageSelect: String = ""
}
