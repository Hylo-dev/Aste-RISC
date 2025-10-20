//
//  ListFiles.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/08/25.
//

import SwiftUI

struct ListFilesView: View {
    
    @EnvironmentObject private var fileSearchViewModel: FileSearchViewModel
    
    @State private var currentHeight: CGFloat
    
    private let maxHeight: CGFloat
    private var onSelect : (FileItem) -> Void
    
    init(onSelect: @escaping (FileItem) -> Void) {
        self.currentHeight       = 0
        self.maxHeight           = 300
        self.onSelect            = onSelect
    }
    
    var body: some View {
        let fileSelectedIndex = self.fileSearchViewModel.fileSelectedIndex
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                LazyVStack(spacing: 0) {
                    
                    if self.fileSearchViewModel.searchBarState == .SHOW_LIST_FILES {

                        ForEach(self.fileSearchViewModel.filesResult.indices, id: \.self) { index in
                            let item = self.fileSearchViewModel.filesResult[index]
                            
                            FileRowView(
                                item: item,
                                currentIndex: index,
                                fileSelectedIndex: fileSelectedIndex
                                
                            ) {
                                self.fileSearchViewModel.fileSelectedIndex = index
                                onSelect(item)
                            }
                        }
                        
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: ContentHeightKey.self, value: geo.size.height)
                    }
                )
            }
            .frame(height: min(currentHeight, maxHeight))
            .onPreferenceChange(ContentHeightKey.self) { measuredHeight in
                withAnimation(.easeInOut(duration: 0.15)) {
                    currentHeight = measuredHeight
                }
                
            }
            .onChange(of: self.fileSearchViewModel.filesResult.count) { _, _ in
                let filesResultCount = self.fileSearchViewModel.filesResult.count
                
                if fileSelectedIndex >= filesResultCount {
                    self.fileSearchViewModel.fileSelectedIndex = max(0, filesResultCount - 1)
                }
                
            }
            .onChange(of: self.fileSearchViewModel.fileSelectedIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.8)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.95, anchor: .top)
                    .combined(with: .opacity)
                    .combined(with: .offset(y: -10)),
                
                removal: .scale(scale: 0.95, anchor: .top)
                    .combined(with: .opacity)
                    .combined(with: .offset(y: -10))
            )
        )
    }
}

