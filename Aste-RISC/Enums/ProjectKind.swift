//
//  ProjectKind.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation

enum ProjectKind {
    case cExe
    case cLib
    case cppExe
    case cppLib

    enum Language {
        case c
        case cpp

        var cmakeLanguage: String {
            switch self {
            case .c:   return "C"
            case .cpp: return "CXX"
            }
        }

        var mainFileName: String {
            switch self {
            case .c:   return "main.c"
            case .cpp: return "main.cpp"
            }
        }
    }

    var language: Language {
        switch self {
        case .cExe, .cLib: return .c
        case .cppExe, .cppLib: return .cpp
        }
    }

    var isLibrary: Bool {
        switch self {
        case .cLib, .cppLib: return true
        case .cExe, .cppExe: return false
        }
    }

    func targetDeclaration(projectName: String, sources: [String]) -> String {
        let sourcesJoined = sources.joined(separator: " ")
        if isLibrary {
            return "add_library(\(projectName) \(sourcesJoined))"
        } else {
            return "add_executable(\(projectName) \(sourcesJoined))"
        }
    }
}
