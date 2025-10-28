//
//  TerminalView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/08/25.
//

import SwiftUI

struct TerminalContainerView: View {
	@EnvironmentObject private var terminal: TerminalOutputModel
	@EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
	
	@Binding var terminalHeight: CGFloat
	@State private var isDragging: Bool = false
	
	@State private var isHoveringSlider: Bool = false
	@State private var showSliderHighlight: Bool = false
	@State private var highlightFadeWorkItem: DispatchWorkItem?
	
	private let minTerminalHeight: CGFloat = 80
	private let maxTerminalHeight: CGFloat = 500
	private let highlightFadeDelay: TimeInterval = 2.0
	private let highlightFadeDuration: Double = 0.25
	
	private static let collapsedHeight: CGFloat = 48
	
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
						
						if newHeight >= Self.collapsedHeight {
							if !self.bodyEditorViewModel.isOutputVisible {
								self.bodyEditorViewModel.isOutputVisible = true
							}
							
							isDragging = true
							
							terminalHeight = min(newHeight, maxTerminalHeight)
						}
						
					}
					.onEnded { _ in
						isDragging = false
						
						if terminalHeight <= minTerminalHeight + 10 {
							withAnimation(.spring()) {
								self.bodyEditorViewModel.isOutputVisible = false
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
						self.bodyEditorViewModel.isOutputVisible.toggle()
						
						if self.bodyEditorViewModel.isOutputVisible && terminalHeight < minTerminalHeight {
							terminalHeight = minTerminalHeight
						}
						
					}
				} label: {
					Image(systemName: "dock.rectangle")
						.foregroundColor(self.bodyEditorViewModel.isOutputVisible ? .accentColor : .primary)
					
				}
				.buttonStyle(.plain)
			}
			.zIndex(1)
			
			if self.bodyEditorViewModel.isOutputVisible {
				Spacer()
			}
			
			// Contain list output assembler
			outputAssembler
		}
		.padding()
		.frame(
			maxWidth: .infinity,
			maxHeight: self.bodyEditorViewModel.isOutputVisible ? terminalHeight : Self.collapsedHeight,
			alignment: .top
		)
		.background(roundedBackgroundTerminal)
		.onAppear(perform: handleOutputAssemblerAppear)
		
	}
	
	private var outputAssembler: some View {
		return ScrollView {
			VStack(alignment: .leading, spacing: 4) {
				ForEach(terminal.messages.indices, id: \.self) { i in
					let item = terminal.messages[i]
					let text = String(cString: item.text).trimmingCharacters(in: .whitespacesAndNewlines)
					
					switch item.type {
						case MESSAGE_INFO:
							Text(text)
								.font(.system(.body, design: .monospaced))
								.foregroundColor(.primary)
								.frame(maxWidth: .infinity, alignment: .leading)
							
						case MESSAGE_WARNING:
							Text(text)
								.font(.system(.body, design: .monospaced))
								.foregroundColor(.yellow)
								.frame(maxWidth: .infinity, alignment: .leading)
							
						case MESSAGE_ERROR:
							Text(text)
								.font(.system(.body, design: .monospaced))
								.foregroundColor(.red)
								.frame(maxWidth: .infinity, alignment: .leading)
							
						default:
							Text(text)
								.font(.system(.body, design: .monospaced))
								.foregroundColor(.primary)
								.frame(maxWidth: .infinity, alignment: .leading)
					}
					
					Divider()
				}

			}
		}
	}
    
    private var roundedBackgroundTerminal: some View {
        RoundedRectangle(cornerRadius: self.bodyEditorViewModel.isOutputVisible ? 26 : 20)
            .fill(.windowBackground)
            .stroke(.secondary.opacity(0.23), style: .init(lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
	
	private func handleOutputAssemblerAppear() { self.terminal.clear() }
}
