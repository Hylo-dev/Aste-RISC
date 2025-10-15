//
//  NavigationItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

struct NavigationItem: Hashable {
    var principalNavigation: NavigationEnum
    var secondaryNavigation: SecondaryNavigationEnum?
    
    var selectedProjectName: String
    var selectedProjectPath: String
}
