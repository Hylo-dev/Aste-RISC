//
//  CreationProjectViewModel.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation
internal import Combine

/// View model for manage read data on terminal
@MainActor
class CreationProjectViewModel: ObservableObject {
	
    /// Variable for save information to new project
    @Published
	var project: NewProjectItem
	
	/// Stabilished creation project status
	@Published
	var creating: Bool
	
	/// Get the IDE global settings
	@Published
	private var globalSetting: GlobalSettings?
	
	/// Save the base directory for the project
	let baseDirectory: URL
	
	init() {
		let info = NewProjectItem()
		
		self.project  = info
		self.creating = false
		
		self.baseDirectory = URL(
			fileURLWithPath: (
				info.path as NSString
		 ).expandingTildeInPath,
			isDirectory: true
		)
	}
	
	func createProjectHandle() async -> (
		projectUrl  : URL?,
		errorMessage: String?
	) {
		var returnValue: (URL?, String?)
		
		creating = true
		
		returnValue = await ProjectCreator.shared.createProject(
			at  : self.baseDirectory,
			name: self.project.name
		)
		
		self.globalSetting?.addRecentProject(
			name: returnValue.1		    ?? "",
			path: returnValue.0?.path() ?? ""
		)
					
		creating = false
		
		return returnValue
	}
	
	/// Return the variable status for creation of projects,
	/// when this is false the creation is not
	func isCreateReady() -> Bool {
		return self.creating ||
			   self.project.name.isEmpty ||
			   self.project.path.isEmpty
	}
}
