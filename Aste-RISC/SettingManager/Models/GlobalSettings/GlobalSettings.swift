//
//  GlobalSettings.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/10/25.
//

import Foundation
import SwiftUI

struct GlobalSettings: SettingsInterface {
    private static let maxProjects = 10
    
    var lastProjectOpened: String
    var editorUse        : Editors
    var themeUsed        : String
    var recentsProjects  : [RecentProject]
    
    init(
        lastProjectOpened: String 		   = "",
        editorUse        : Editors 		   = .native,
        themeUse         : String 		   = "gruvbox_material.json",
        recentsProjects  : [RecentProject] = []
        
    ) {
        self.lastProjectOpened = lastProjectOpened
        self.editorUse         = editorUse
        self.themeUsed         = themeUse
        self.recentsProjects   = recentsProjects
        
    }
    
    init() { self.init(lastProjectOpened: "", recentsProjects: []) }
    
    var fileName = "global_settings.json"
    var id = UUID()

    mutating func addRecentProject(
		name: String,
		path: String
	) {
        let project = RecentProject(name: name, path: path)
        
        if let existingIndex = self.recentsProjects.firstIndex(
			where: { $0.path == path }
		) {
            self.recentsProjects.remove(at: existingIndex)
        }

        self.recentsProjects.insert(project, at: 0)

        // Limit array to max quantity
        if self.recentsProjects.count > Self.maxProjects {
            self.recentsProjects = Array(
				self.recentsProjects.prefix(Self.maxProjects)
			)
        }
    }
    
    mutating func removeProject(at offsets: IndexSet) {
        self.recentsProjects.remove(atOffsets: offsets)
    }
}
