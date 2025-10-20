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
final class NavigationState: ObservableObject {
    
    /// Contains all data
    @Published private(set) var navigationItem: NavigationItem
    
    /// Save and load state on JSON
    private let lastStateApp: LastAppStateStore

    init() {
        self.lastStateApp = LastAppStateStore()

        self.navigationItem = NavigationItem(
            principalNavigation: .home,
            selectedProjectName: URL(string: lastStateApp.currentState.lastPathOpened)?.lastPathComponent ?? "",
            selectedProjectPath: lastStateApp.currentState.lastPathOpened
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
        lastStateApp.changeState(path: path)
    }
}
