//
//  Language.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

enum Language: String, Codable {
    case c
    case cpp
    case cmake

    var langId: String {
        switch self {
        case .c: return "c"
        case .cpp: return "cpp"
        case .cmake: return "cmake"
        }
    }
}
