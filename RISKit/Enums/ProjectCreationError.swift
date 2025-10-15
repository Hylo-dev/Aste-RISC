//
//  ProjectCreationError.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

import Foundation

enum ProjectCreationError: Error, LocalizedError {
    case invalidProjectName
    case projectAlreadyExists(URL)
    case templateNotFound(String)
    case writeFailed(URL)
    case bundleReadFailed(URL)

    var errorDescription: String? {
        switch self {
        case .invalidProjectName:
            return "This name is not valid."
            
        case .projectAlreadyExists(let url):
            return "The folder is alredy exists: \(url.path)"
            
        case .templateNotFound(let name):
            return "Not found template in bundle: \(name)"
            
        case .writeFailed(let url):
            return "Write is failed: \(url.path)"
            
        case .bundleReadFailed(let url):
            return "Read bundle file is filed: \(url.path)"
            
        }
    }
}
