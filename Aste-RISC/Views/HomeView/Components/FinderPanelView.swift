//
//  FinderPanelView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

import AppKit
import Foundation

func showFinderPanel(navigationViewModel: NavigationViewModel) {
    let panel = NSOpenPanel()
    
    panel.canChooseDirectories = true
    panel.canChooseFiles = false
    panel.allowsMultipleSelection = false
    panel.prompt = "Open"
    panel.title = "Select Project Directory"

    panel.begin { response in
        if response == .OK, let url = panel.url {

            Task {
				if navigationViewModel.selectedProjectPath != url.path ||
					navigationViewModel.selectedProjectName != url.lastPathComponent {
                    
                    navigationViewModel.setProjectPath(url: url.path())
                    navigationViewModel.setProjectName(name: url.lastPathComponent)
                    navigationViewModel.setSecondaryNavigation(secondaryNavigation: .openProject)
                }
            }
        }
    }
}

func closeCreateProjectPanel(navigationState: NavigationViewModel) {
    navigationState.cleanSecondaryNavigation()
}
