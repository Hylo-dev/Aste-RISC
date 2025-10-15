//
//  CreationProjectViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation
internal import Combine

@MainActor
/// View model for manage read data on terminal
final class CreationProjectViewModel: ObservableObject {
    /// Info new project
    @Published var defaultProject = NewProjectItem()

    var nameProject: String {
        get { defaultProject.nameProject }
        set { defaultProject.nameProject = newValue; defaultProject = defaultProject }
        
    }
    
    var locationProject: String {
        get { defaultProject.locationProject }
        set { defaultProject.locationProject = newValue; defaultProject = defaultProject }
        
    }
    
    var baseDirectoryURL: URL {
        let expanded = (defaultProject.locationProject as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expanded, isDirectory: true)
    }
    
    /// Create a project
    func createProject() async throws -> URL {
        return try await ProjectCreator.shared.createProject(
            at: baseDirectoryURL,
            name: defaultProject.nameProject
        )
    }
}
