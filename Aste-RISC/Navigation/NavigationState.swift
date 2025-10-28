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
class NavigationState: ObservableObject {
    
    /// Contains all data
    @Published private(set) var navigationItem: NavigationItem
        
    private var settingsManager: SettingsManager = SettingsManager()

    init() {
        self.navigationItem = NavigationItem(
            principalNavigation: .home,
            secondaryNavigation: nil,
            selectedProjectName: URL(
                string: self.settingsManager.load(
                    file: "global_settings.json",
                    GlobalSettings.self
                )?.lastProjectOpened ?? ""
            )?.lastPathComponent ?? "",
            
            selectedProjectPath: self.settingsManager.load(
                file: "global_settings.json",
                GlobalSettings.self
            )?.lastProjectOpened ?? ""
        )
    }
    
    // MARK: - Set attributes
    
    /// Change principal navigation value
    func setPrincipalNavigation(principalNavigation: NavigationEnum) {
        self.navigationItem.principalNavigation = principalNavigation
    }
    
    /// Change secondary navigation value
    func setSecondaryNavigation(currentSecondaryNavigation: SecondaryNavigationEnum) {
        self.navigationItem.secondaryNavigation = currentSecondaryNavigation
    }
    
    /// Change curret project path
    func setProjectPath(url: String) {
        self.navigationItem.selectedProjectPath = url
    }
    
    /// Change current project name
    func setProjectName(name: String) {
        self.navigationItem.selectedProjectName = name
        
    }
    
    /// Change all project information
    func setProjectInformation(url: String, name: String) {
        self.navigationItem.selectedProjectPath = url
        self.navigationItem.selectedProjectName = name
    }
    
    // MARK: - Clean attributes methods
    
    /// Delete information project
    func cleanProjectInformation() {
        self.navigationItem.selectedProjectName = ""
        self.navigationItem.selectedProjectPath = ""
    }
    
    /// Delete secondary navigation
    func cleanSecondaryNavigation() {
        self.navigationItem.secondaryNavigation = nil
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
}
