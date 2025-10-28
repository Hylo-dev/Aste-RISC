//
//  FinderPanelView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

import AppKit
import Foundation

func showFinderPanel(navigationState: NavigationState) {
    let panel = NSOpenPanel()
    
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.allowsMultipleSelection = false
    panel.prompt = "Open"
    panel.title = "Select Project Directory"

    panel.begin { response in
        if response == .OK, let url = panel.url {

            Task {
                if navigationState.navigationItem.selectedProjectPath != url.path || navigationState.navigationItem.selectedProjectName != url.lastPathComponent {
                    
                    navigationState.setProjectPath(url: url.path())
                    navigationState.setProjectName(name: url.lastPathComponent)
                    navigationState.setSecondaryNavigation(currentSecondaryNavigation: .CONTROL_OPEN_PROJECT)
                }
            }
        }
    }
}

func closeCreateProjectPanel(navigationState: NavigationState) {
    navigationState.cleanSecondaryNavigation()
}
