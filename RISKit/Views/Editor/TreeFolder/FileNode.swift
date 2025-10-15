//
//  FileNode.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI
import Foundation
internal import Combine

import AppKit
import SwiftUI
import Foundation
import AppKit

final class FileNode: ObservableObject, Identifiable {
    let id: String
    let url: URL
    let name: String
    let isDirectory: Bool

    @Published var children: [FileNode] = []
    @Published var isExpanded: Bool = false
    @Published var icon: Image? = nil

    private var loaded: Bool = false

    init(url: URL) {
        self.url = url
        self.id = url.path
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
    func loadChildrenPreservingState(async: Bool = true, forceReload: Bool = false) {
        guard isDirectory else { return }

        if loaded && !forceReload {
            return
        }

        let work = {
            let fm = FileManager.default
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
            let urls: [URL]
            
            if let content = try? fm.contentsOfDirectory(
                at: self.url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: options
                
            ) {
                
                urls = content.sorted { a, b in
                    let aa = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    let bb = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    
                    if aa == bb {
                        return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
                    }

                    return aa && !bb
                }
            } else {
                urls = []
            }

            DispatchQueue.main.async { [weak self] in
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
                self.loaded = true

                for child in self.children {
                    if child.isDirectory && child.isExpanded {
                        child.loadChildrenPreservingState(async: true, forceReload: forceReload)
                        
                    }
                }
            }
        }

        if async {
            DispatchQueue.global(qos: .userInitiated).async {
                work()
                
            }
            
        } else {
            work()
            
        }
    }

    private func loadIcon() {
        let nsIcon = NSWorkspace.shared.icon(forFile: url.path)
        nsIcon.size = NSSize(width: 14, height: 14)
        self.icon = Image(nsImage: nsIcon)
        
    }
}
