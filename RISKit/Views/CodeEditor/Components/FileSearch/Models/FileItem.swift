//
//  FileItem.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation

struct FileItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
}
