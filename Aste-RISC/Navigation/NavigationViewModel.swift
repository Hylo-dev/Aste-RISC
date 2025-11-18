//
//  NavigationState.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

internal import Combine
import AppKit
import SwiftUI

@MainActor
/// NavigationState class contains all information ide, settings, lang, projects open and close state
class NavigationViewModel: ObservableObject {
    
    @Published private(set) var principalNavigation: PrincipalNavigationState
	@Published private(set) var secondaryNavigation: SecondaryNavigationState?
	
	@Published private(set) var selectedProjectName: String
	@Published private(set) var selectedProjectPath: String
	
    private var settingsManager: SettingsManager = SettingsManager()

    init() {
		self.principalNavigation = .home
		self.secondaryNavigation = nil
		
		let path = self.settingsManager.load(
			file: "global_settings.json",
			GlobalSettings.self
		)?.lastProjectOpened ?? ""
				
		self.selectedProjectName = URL(string: path)?.lastPathComponent ?? ""
		self.selectedProjectPath = path
	}
    
    // MARK: - Set attributes
    
    /// Change principal navigation value
    func setPrincipalNavigation(principalNavigation: PrincipalNavigationState) {
        self.principalNavigation = principalNavigation
    }
    
    /// Change secondary navigation value
    func setSecondaryNavigation(secondaryNavigation: SecondaryNavigationState) {
        self.secondaryNavigation = secondaryNavigation
    }
    
    /// Change curret project path
    func setProjectPath(url: String) {
        self.selectedProjectPath = url
    }
    
    /// Change current project name
    func setProjectName(name: String) {
        self.selectedProjectName = name
        
    }
    
    /// Change all project information
    func setProjectInformation(
		url: String,
		name: String
	) {
        self.selectedProjectPath = url
        self.selectedProjectName = name
    }
    
    // MARK: - Clean attributes methods
    
    /// Delete information project
    func cleanProjectInformation() {
        self.selectedProjectName = ""
        self.selectedProjectPath = ""
    }
    
    /// Delete secondary navigation
    func cleanSecondaryNavigation() {
        self.secondaryNavigation = nil
    }
    
    // MARK: - Save current project state
    
    /// Save on file JSON current state
    func saveCurrentProjectState(path: String) {
        var globalSettings = self.settingsManager.load(
            file: "global_settings.json",
            GlobalSettings.self
        )
        
        if globalSettings != nil {
            globalSettings?.lastProjectOpened = path
            self.settingsManager.save(globalSettings!)
        }
    }
	
	func isSettingsFolderExist() -> Bool {
		let path = FileManager.default.urls(
			for: .applicationSupportDirectory,
			in : .userDomainMask
		).first!
		
		let settingsFolder = path.appendingPathComponent("RISKit")
								 .appendingPathComponent("Settings")
		
		return FileManager.default.fileExists(atPath: settingsFolder.path)
	}
}
