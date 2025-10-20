//
//  TerminalView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/08/25.
//

import SwiftUI

struct TerminalContainerView: View {
    @Binding var terminalHeight: CGFloat
    @Binding var isBottomVisible: Bool
    @State private var isDragging: Bool = false

    @State private var isHoveringSlider: Bool = false
    @State private var showSliderHighlight: Bool = false
    @State private var highlightFadeWorkItem: DispatchWorkItem?
    
    let collapsedHeight: CGFloat
    private let minTerminalHeight: CGFloat = 80
    private let maxTerminalHeight: CGFloat = 500
    private let highlightFadeDelay: TimeInterval = 2.0
    private let highlightFadeDuration: Double = 0.25
    
    var body: some View {
                
        Rectangle()
            .fill(Color.clear)
            .frame(height: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.18))
                    .frame(height: 4)
                    .padding(.horizontal, 40)
                    .opacity(showSliderHighlight ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: highlightFadeDuration), value: showSliderHighlight)
            )
            .onHover { isHover in
                isHoveringSlider = isHover
                
                if isHover {
                    highlightFadeWorkItem?.cancel()
                    withAnimation(.easeInOut(duration: 0.22)) {
                        showSliderHighlight = true
                    }
                    
                } else {
                    let workItem = DispatchWorkItem {
                        withAnimation(.easeInOut(duration: highlightFadeDuration)) {
                            showSliderHighlight = false
                        }
                    }
                    
                    highlightFadeWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + highlightFadeDelay, execute: workItem)
                    
                }
            }
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        
                        let newHeight = terminalHeight - value.translation.height
                        
                        if newHeight >= collapsedHeight {
                            if !isBottomVisible { isBottomVisible = true }
                            
                            isDragging = true
                            
                            terminalHeight = min(newHeight, maxTerminalHeight)
                        }
                        
                    }
                    .onEnded { _ in
                        isDragging = false
                        
                        if terminalHeight <= minTerminalHeight + 10 {
                            withAnimation(.spring()) {
                                isBottomVisible = false
                            }
                        }
                    }
            )
            .modifier(ResizeCursorModifier())
            .padding(.vertical, 2)
        
        // Terminal area (bottom)
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        isBottomVisible.toggle()
                        
                        if isBottomVisible && terminalHeight < minTerminalHeight {
                            terminalHeight = minTerminalHeight
                        }
                        
                    }
                } label: {
                    Image(systemName: "dock.rectangle")
                        .foregroundColor(isBottomVisible ? .accentColor : .primary)
                    
                }
                .buttonStyle(.plain)
            }
            .zIndex(1)
            
            if isBottomVisible {
                Spacer()
            }
            
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            maxHeight: isBottomVisible ? terminalHeight : collapsedHeight,
            alignment: .top
        )
        .background(roundedBackgroundTerminal)
        
    }
    
    private var roundedBackgroundTerminal: some View {
        RoundedRectangle(cornerRadius: isBottomVisible ? 26 : 20)
            .fill(.windowBackground)
            .stroke(.secondary.opacity(0.23), style: .init(lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
}
