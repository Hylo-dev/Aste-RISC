//
//  NewProjectItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

import Foundation
internal import Combine

class NewProjectItem: ObservableObject {
	
	@Published
    var name: String = ""
	
	@Published
    var path: String = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(
			"\(Bundle.main.appName)Projects",
			isDirectory: true
		).path
}
