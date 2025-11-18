//
//  CreationProjectViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation
internal import Combine

@MainActor /// View model for manage read data on terminal
class CreationProjectViewModel: ObservableObject {
    /// Info new project
    @Published
	var project = NewProjectItem()
	
	/// State creation project
	@Published
	var creating: Bool = false
    
    var baseDirectoryURL: URL {
        let expanded = (
			self.project.path as NSString
		).expandingTildeInPath
		
        return URL(fileURLWithPath: expanded, isDirectory: true)
    }
	
	func createProjectHandle() async -> (
		projectUrl  : URL?,
		errorMessage: String?
	) {
		var returnValue: (URL?, String?)
		
		creating = true
		
		returnValue = await ProjectCreator.shared.createProject(
			at  : baseDirectoryURL,
			name: self.project.name
		)
					
		creating = false
		
		return returnValue
	}
}
