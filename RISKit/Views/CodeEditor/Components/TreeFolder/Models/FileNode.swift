//
//  FileNode.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI
import Foundation
internal import Combine

final class FileNode: ObservableObject, Identifiable {
    let id: String
    let url        : URL
    let name       : String
    let isDirectory: Bool
    
    private var loaded: Bool = false

    @Published var children  : [FileNode] = []
    @Published var isExpanded: Bool       = false
    @Published var icon      : Image?     = nil

    init(url: URL) {
        self.id   = url.path
        self.url  = url
        self.name = url.lastPathComponent

        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue

        loadIcon()
    }

    /// Load or reload children, not delete old data
    /// - Parameters:
    ///   - async: if true l'I/O is make on background (default true)
    ///   - forceReload: if true force reload (default false)
    func loadChildrenPreservingState(forceReload: Bool = false) {
        guard isDirectory else { return } // Assert correct value, if not equals exit
        
        if loaded && !forceReload { return }
        
        // Set async work
        let work = {
            let fileManager = FileManager.default
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
            let urls   : [URL]
            
            if let content = try? fileManager.contentsOfDirectory(
                at: self.url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: options
                
            ) {
                urls = content.sorted { first, second in
                    let isFirstDir  = (try? first.resourceValues(forKeys: [.isDirectoryKey]).isDirectory)  ?? false
                    let isSecondDir = (try? second.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    
                    if isFirstDir == isSecondDir {
                        return first.lastPathComponent.lowercased() < second.lastPathComponent.lowercased()
                    }

                    return isFirstDir && !isSecondDir
                }
                
            } else { urls = [] }

            Task { @MainActor [weak self] in
                guard let self = self else { return }

                var existingMap = Dictionary(uniqueKeysWithValues: self.children.map { ($0.id, $0) })
                var newChildren: [FileNode] = []

                for url in urls {
                    if let existing = existingMap[url.path] {
                        newChildren.append(existing)
                        existingMap.removeValue(forKey: url.path)
                        
                    } else {
                        let node = FileNode(url: url)
                        newChildren.append(node)
                        
                    }
                }

                self.children = newChildren
                self.loaded   = true

                for child in self.children {
                    if child.isDirectory && child.isExpanded {
                        child.loadChildrenPreservingState(forceReload: forceReload)
                    }
                }
            }
        }

        Task { work() }
    }

    private func loadIcon() {
        let nsIcon  = NSWorkspace.shared.icon(forFile: url.path)
        nsIcon.size = NSSize(width: 14, height: 14)
        self.icon   = Image(nsImage: nsIcon)
        
    }
}
