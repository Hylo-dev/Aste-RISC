//
//  FileSearchView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI

struct FileSearchView: View {
    @StateObject private var fileSearchViewModel: FileSearchViewModel
    
    private let totalWidth: CGFloat
    private let buttonSize: CGFloat
    private var onSelect  : (FileItem) -> Void // CallBack function
    
    init(
        directory: URL,
        onSelect: @escaping (FileItem) -> Void
    ) {
        self._fileSearchViewModel = StateObject(wrappedValue: FileSearchViewModel(directory: directory))
        self.onSelect             = onSelect
        self.totalWidth           = 600
        self.buttonSize           = 65
    }
    
    var body: some View {
        
        VStack {
            
            GlassEffectContainer(spacing: 18) {
                
                HStack(alignment: .top, spacing: 15) {
                    let searchBarState = self.fileSearchViewModel.searchBarState
                    let textAreaWidth  = searchBarState == .SHOW_CREATE_BUTTON ?
                    totalWidth - buttonSize :
                    totalWidth
                    
                    // Spotlight and list
                    VStack(spacing: 15) {
                        
                        // Contains text field for search element on project
                        textFieldSearch
                        
                        // Lists element
                        listElementsSearched
                        
                    }
                    .padding()
                    .glassEffect(in: .rect(cornerRadius: 36))
                    .frame(width: textAreaWidth)
                    .onKeyPress { keyPress in
                        self.fileSearchViewModel.keyboardState(press: keyPress, onSelect: onSelect)
                    }
                    .onChange(of: fileSearchViewModel.filesResult) {
                        self.fileSearchViewModel.fileSelectedIndex = 0
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            let showList = !fileSearchViewModel.filesResult.isEmpty &&
                            fileSearchViewModel.searchText != ""
                            
                            if searchBarState == .SEARCH_FILE && showList {
                                self.fileSearchViewModel.searchBarState = .SHOW_LIST_FILES
                                
                            } else if searchBarState == .SHOW_LIST_FILES && !showList {
                                self.fileSearchViewModel.searchBarState = .SEARCH_FILE
                                
                            }
                        }
                    }
                    
                    buttonCreateFile // Button for create new file
                    
                }
            }
            
            Spacer()
            
        }
        .padding(.top, 127)
    }
    
    // MARK: TextField
    private var textFieldSearch: some View {
        let searchBarState = fileSearchViewModel.searchBarState
        
        return HStack(spacing: 10) {
            
            switch searchBarState {
            case .CREATE_FILE:
                Image(systemName: "document.badge.plus")
                    .foregroundColor(.secondary)
                    .font(.title)
                
            default:
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.title)
                
            }
            
            TextField(
                searchBarState == .SEARCH_FILE ||
                searchBarState == .SHOW_LIST_FILES ?
                "Search File" :
                    "Add File",
                text: $fileSearchViewModel.searchText
            )
            .font(.title)
            .textFieldStyle(.plain)
            .onSubmit {
                guard !fileSearchViewModel.filesResult.isEmpty else { return }
                
                let fileSelectedIndex = self.fileSearchViewModel.fileSelectedIndex
                onSelect(self.fileSearchViewModel.filesResult[fileSelectedIndex])
            }
            
        }
    }
    
    // MARK: List elements
    private var listElementsSearched: some View {
        let searchBarState = fileSearchViewModel.searchBarState
        
        return Group {
            if searchBarState == .SHOW_LIST_FILES || searchBarState == .CREATE_FILE {
                Divider()
                
                ListFilesView() { file in onSelect(file) }
                    .environmentObject(self.fileSearchViewModel)
            }
        }
    }
    
    // MARK: Button for create file
    private var buttonCreateFile: some View {
        let searchBarState = fileSearchViewModel.searchBarState
        
        return Group {
            if searchBarState == .SHOW_CREATE_BUTTON {
                Button {
                    
                    
                } label: {
                    Image(systemName: "document.badge.plus")
                        .font(.system(size: 19))
                        .frame(width: 55, height: 55)
                        .contentShape(Circle())
                    
                }
                .buttonStyle(.plain)
                .glassEffect(
                    .regular.tint(
                        searchBarState == .SHOW_CREATE_BUTTON ?
                        Color.accentColor :
                        Color.clear
                    ),
                    in: .circle
                )
                .clipShape(Circle())
                .transition(.move(edge: .leading).combined(with: .opacity))
                
            } else {
                Color.clear
                    .frame(width: 0, height: buttonSize)
                    .allowsHitTesting(false)
                
            }
        }
    }
}
