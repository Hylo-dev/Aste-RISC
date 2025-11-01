//
//  RecentProject.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import Foundation

struct RecentProject: Identifiable, Codable, Equatable, Hashable {
    var id	: String { path }
    let name: String
    let path: String

    static func == (lhs: RecentProject, rhs: RecentProject) -> Bool {
        lhs.path == rhs.path
    }
}
