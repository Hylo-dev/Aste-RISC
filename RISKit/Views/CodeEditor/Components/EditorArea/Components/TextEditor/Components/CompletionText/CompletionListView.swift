//
//  CompletationListView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 03/09/25.
//

import SwiftUI

struct CompletionListView: View {
    let items: [CompletionItem]
    let onSelect: (CompletionItem) -> Void
    let onDismiss: () -> Void

    @State private var selectedIndex: Int = 0
    @State private var currentCompletionItem: CompletionItem? = nil

    private let rowHeight: CGFloat = 28
    private let maxHeight: CGFloat = 250

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        
                        ForEach(Array(items.enumerated()), id: \.1.id) { idx, item in
                            
                            completionRow(item: item, index: idx)
                                .id(idx)
                                .frame(height: rowHeight)
                            
                        }
                    }
                }
                .frame(width: 400, height: min(CGFloat(items.count) * (rowHeight + 10) + 16, maxHeight))
                .padding()
                .glassEffect(in: .rect(cornerRadius: 15))
                .onChange(of: selectedIndex) { _, newIndex in
                    currentCompletionItem = items[newIndex]
                    
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
                .onChange(of: items) { _, newItems in

                    selectedIndex = 0
                    if !newItems.isEmpty {
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo(0, anchor: .center)
                        }
                        
                        currentCompletionItem = newItems.first
                    }
                }
            }

            VStack(alignment: .leading) {
                
                if currentCompletionItem != nil {
                    CompletionHighlightedView(text: "\(currentCompletionItem?.text ?? "") -> \(currentCompletionItem?.detail ?? "")")
                }
                
                Text(currentCompletionItem?.documentation ?? "nil")
            }
            .padding()
        }
        .onAppear {
            selectedIndex = 0
            currentCompletionItem = items.first
            
        }
        .onReceive(NotificationCenter.default.publisher(for: .completionSelectionChanged)) { notification in
            if let newIndex = notification.userInfo?["selectedIndex"] as? Int {
                selectedIndex = newIndex
            }
        }
    }

    @ViewBuilder
    private func completionRow(item: CompletionItem, index: Int) -> some View {
        Text(item.insertText)
            .font(.system(.title3, design: .monospaced))
            .foregroundStyle(selectedIndex == index ? .primary : .secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .background(selectedIndex == index ? Color.secondary.opacity(0.18) : Color.clear)
            .cornerRadius(6)
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedIndex == index {
                    onSelect(item)
                }
                
                currentCompletionItem = item
                selectedIndex = index
            }
    }

    func moveSelection(by offset: Int) {
        guard !items.isEmpty else { return }
        selectedIndex = (selectedIndex + offset + items.count) % items.count
    }

    func confirmSelection() {
        if items.indices.contains(selectedIndex) {
            onSelect(items[selectedIndex])
        }
    }
}
