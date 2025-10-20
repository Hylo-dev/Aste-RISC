//
//  FileSearchViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI
internal import Combine

class FileSearchViewModel: ObservableObject {
    @Published var searchText       : String
    @Published var fileSelectedIndex: Int
    @Published var searchBarState   : SearchBarState
    @Published var filesResult      : [FileItem]
    
    private var allFiles: [FileItem]
    private var cancellables: Set<AnyCancellable>
    
    init(directory: URL) {
        self.searchText        = ""
        self.filesResult           = []
        self.fileSelectedIndex = 0
        self.searchBarState      = .SEARCH_FILE
        self.allFiles          = []
        self.cancellables      = Set<AnyCancellable>()
        
        loadFiles(from: directory)
        
        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in self?.filterResults(for: query) }
            .store(in: &cancellables)
    }
    
    private func loadFiles(from directory: URL) {
        var files: [FileItem] = []
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if !fileURL.hasDirectoryPath {
                    files.append(FileItem(name: fileURL.lastPathComponent, url: fileURL))
                }
                
            }
        }
        
        self.allFiles = files
    }
    
    private func filterResults(for query: String) {
        if query.isEmpty {
            filesResult = []
            
        } else {
            filesResult = allFiles.filter { $0.name.localizedCaseInsensitiveContains(query) }
            
        }
    }
    
    func keyboardState(
        press keyPress: KeyPress,
        onSelect      : (FileItem) -> Void
        
    ) -> KeyPress.Result {
        switch keyPress.key {
        case .downArrow:
            
            // Case File's loads
            if searchBarState == .SHOW_LIST_FILES {
                guard !filesResult.isEmpty else { return .ignored }
                
                if fileSelectedIndex < filesResult.count - 1 { fileSelectedIndex += 1 }
                
            } else if searchBarState == .CREATE_FILE && fileSelectedIndex < 2 {
                fileSelectedIndex += 1
                
            }
            
            return .handled
            
        case .upArrow:
            if searchBarState == .SHOW_LIST_FILES {
                guard !filesResult.isEmpty else { return .ignored }
            }
            
            if fileSelectedIndex > 0 { fileSelectedIndex -= 1
            }
            return .handled
            
        case .rightArrow:
            if searchBarState  != .SHOW_CREATE_BUTTON &&
                searchBarState != .SHOW_LIST_FILES    &&
                searchBarState != .CREATE_FILE {
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    searchBarState    = .SHOW_CREATE_BUTTON
                    fileSelectedIndex = 0
                    
                }
            }
            
            return .handled
            
        case .leftArrow:
            if searchBarState  != .SEARCH_FILE &&
                searchBarState != .SHOW_LIST_FILES &&
                searchBarState != .CREATE_FILE {
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    searchBarState    = .SEARCH_FILE
                    fileSelectedIndex = 0
                }
            }
            
            return .handled
            
        case .return:
            switch searchBarState {
            case .SHOW_LIST_FILES:
                guard !filesResult.isEmpty else { return .ignored }
                                
                onSelect(filesResult[fileSelectedIndex])
                
            case .SHOW_CREATE_BUTTON:
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    searchBarState = .CREATE_FILE
                }
            
            default:
                break
            }
            
            return .handled
            
        case .escape:
            if searchBarState == .CREATE_FILE {
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    searchBarState = .SHOW_CREATE_BUTTON
                }
                
            }
            
            return .handled
            
        default:
            return .ignored
        }
    }
}

