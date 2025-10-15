//
//  FileSearchView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI

struct FileSearchView: View {
    @ObservedObject private var viewModel: FileSearchViewModel
    var onSelect: (FileItem) -> Void
    
    @State private var selectedListIndex: Int
    @State private var finderStatus     : FinderStatus
    
           private let totalWidth       : CGFloat
           private let buttonSize       : CGFloat
    
    init(directory: URL, onSelect: @escaping (FileItem) -> Void) {
        self.viewModel = FileSearchViewModel(directory: directory)
        self.onSelect = onSelect
        
        self._selectedListIndex = State(initialValue: 0)
        self._finderStatus      = State(initialValue: .SEARCH_FILE)
        
        self.totalWidth = 600
        self.buttonSize = 65
    }
    
    var body: some View {
        
        VStack {
            
            GlassEffectContainer(spacing: 18) {
                
                HStack(alignment: .top, spacing: 15) {
                    
                    let textAreaWidth = finderStatus == .SHOW_CREATE_BUTTON ? totalWidth - buttonSize : totalWidth
                    
                    // Spotlight and list
                    VStack(spacing: 15) {
                        
                        HStack(spacing: 10) {
                            
                            switch finderStatus {
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
                                finderStatus == .SEARCH_FILE || finderStatus == .SHOW_LIST_FILES ? "Search File" : "Add File", text: $viewModel.searchText
                            )
                                .font(.title)
                                .textFieldStyle(.plain)
                                .onSubmit { selectCurrent() }
                            
                        }
                    
                        if finderStatus == .SHOW_LIST_FILES || finderStatus == .CREATE_FILE {
                        
                            Divider() // Fino A Ieri -- Drast
                            
                            ListFilesView(
                                viewModel        : viewModel,
                                selectedListIndex: $selectedListIndex,
                                typeListShow     : $finderStatus
                                    
                            ) { file in
                                onSelect(file)
                            }
                        }
                                    
                    }
                    .padding()
                    .glassEffect(in: .rect(cornerRadius: 36))
                    .frame(width: textAreaWidth)
                    .onKeyPress { keyPress in
                        
                        switch keyPress.key {
                        case .downArrow:
                            
                            // Case File's loads
                            if finderStatus == .SHOW_LIST_FILES {
                                guard !viewModel.results.isEmpty else { return .ignored }
                                
                                if selectedListIndex < viewModel.results.count - 1 {
                                    selectedListIndex += 1
                                }
                                
                            } else if finderStatus == .CREATE_FILE && selectedListIndex < 2 {
                                selectedListIndex += 1
                                
                            }
                            
                            
                            return .handled
                            
                        case .upArrow:
                            if finderStatus == .SHOW_LIST_FILES {
                                guard !viewModel.results.isEmpty else { return .ignored }
                            }
                            
                            if selectedListIndex > 0 {
                                selectedListIndex -= 1
                            }
                            return .handled
                            
                        case .rightArrow:
                            if finderStatus != .SHOW_CREATE_BUTTON && finderStatus != .SHOW_LIST_FILES && finderStatus != .CREATE_FILE {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    finderStatus = .SHOW_CREATE_BUTTON
                                    selectedListIndex = 0
                                }
                            }
                            
                            return .handled
                            
                        case .leftArrow:
                            if finderStatus != .SEARCH_FILE && finderStatus != .SHOW_LIST_FILES && finderStatus != .CREATE_FILE {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    finderStatus = .SEARCH_FILE
                                    selectedListIndex = 0
                                }
                            }
                            
                            return .handled
                            
                        case .return:
                            switch finderStatus {
                            case .SHOW_LIST_FILES:
                                guard !viewModel.results.isEmpty else { return .ignored }
                                selectCurrent()
                                
                            case .SHOW_CREATE_BUTTON:
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    finderStatus = .CREATE_FILE
                                }
                            
                            default:
                                break
                            }
                            
                            return .handled
                            
                        case .escape:
                            if finderStatus == .CREATE_FILE {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    finderStatus = .SHOW_CREATE_BUTTON
                                    
                                }
                                
                            }
                            
                            return .handled
                            
                        default:
                            return .ignored
                        }
                    }
                    .onChange(of: viewModel.results) {
                        selectedListIndex = 0
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            let showList = !viewModel.results.isEmpty && viewModel.searchText != ""
                             
                            if finderStatus == .SEARCH_FILE && showList {
                                finderStatus = .SHOW_LIST_FILES
                                
                            } else if finderStatus == .SHOW_LIST_FILES && !showList {
                                finderStatus = .SEARCH_FILE
                                
                            }
                        }
                    }
                    
                    if finderStatus == .SHOW_CREATE_BUTTON {
                        Button {
                            
                            
                        } label: {
                            Image(systemName: "document.badge.plus")
                                .font(.system(size: 19))
                                .frame(width: 55, height: 55)
                                .contentShape(Circle())
                            
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.tint(finderStatus == .SHOW_CREATE_BUTTON ? Color.accentColor : Color.clear), in: .circle)
                        .clipShape(Circle())
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        
                    } else {
                        Color.clear
                            .frame(width: 0, height: buttonSize)
                            .allowsHitTesting(false)
                    }
                    
                }
            }
            
            Spacer()
            
        }
        .padding(.top, 127)
    }
    
    private func selectCurrent() {
        guard !viewModel.results.isEmpty else { return }
        onSelect(viewModel.results[selectedListIndex])
    }
}
