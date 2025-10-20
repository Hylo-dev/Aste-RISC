//
//  ListFiles.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/08/25.
//

import SwiftUI

struct ListFilesView: View {
    
    private struct ContentHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    @ObservedObject private var viewModel        : FileSearchViewModel
    @State          private var currentHeight    : CGFloat
    @Binding        private var selectedListIndex: Int
    @Binding        private var typeListShow     : FinderStatus
                            var onSelect         : (FileItem) -> Void
    
    private let maxHeight: CGFloat
    
    init(
        viewModel        : FileSearchViewModel,
        selectedListIndex: Binding<Int>,
        typeListShow     : Binding<FinderStatus>,
        onSelect         : @escaping (FileItem) -> Void
    ) {
        self.viewModel          = viewModel
        self.currentHeight      = 0
        self._selectedListIndex = selectedListIndex
        self._typeListShow      = typeListShow
        self.onSelect           = onSelect
        
        self.maxHeight          = 300
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                LazyVStack(spacing: 0) {
                    
                    if typeListShow == .SHOW_LIST_FILES {

                        ForEach(viewModel.results.indices, id: \.self) { index in
                            let item = viewModel.results[index]
                            
                            HStack(alignment: .center, spacing: 12) {
                                Image(nsImage: IconCache.shared.icon(for: item.url))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 26, height: 26)
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                    
                                    Text(item.url.deletingLastPathComponent().path)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(10)
                            .background(index == selectedListIndex ? Color.accentColor.opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                            .id(index)
                            .onTapGesture {
                                selectedListIndex = index
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
            .onChange(of: viewModel.results.count) { _, _ in
                if selectedListIndex >= viewModel.results.count {
                    selectedListIndex = max(0, viewModel.results.count - 1)
                }
                
            }
            .onChange(of: selectedListIndex) { _, newIndex in
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

