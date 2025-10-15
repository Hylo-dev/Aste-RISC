//
//  FileType.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/08/25.
//

enum FileType: String, Codable {
    case asm

    var fileExtension: String {
        switch self {
        case .asm    : return "s"
        }
    }
}
