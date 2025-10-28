//
//  CallFrameView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct CallFrameView: View {
	private let frame: CallFrame
	private let frameIndex: Int
	@Binding var isExpanded: Bool
	
	init(
		frame	  : CallFrame,
		frameIndex: Int,
		isExpanded: Binding<Bool>
	) {
		self.frame = frame
		self.frameIndex = frameIndex
		self._isExpanded = isExpanded
		
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Frame header
			Button(action: { withAnimation { isExpanded.toggle() } }) {
				HStack {
					Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
						.font(.caption)
						.foregroundColor(.secondary)
					
					VStack(alignment: .leading, spacing: 2) {
						HStack {
							Text("Frame #\(frameIndex)")
								.font(.headline)
							
							if let ra = frame.returnAddress {
								Text("→ 0x\(String(format: "%x", ra))")
									.font(.caption)
									.foregroundColor(.orange)
									.padding(.horizontal, 6)
									.padding(.vertical, 2)
									.background(Color.orange.opacity(0.2))
									.cornerRadius(4)
							}
						}
						
						Text("0x\(String(format: "%08x", frame.startAddress)) • \(frame.size) bytes")
							.font(.caption2)
							.foregroundColor(.secondary)
							.monospacedDigit()
					}
					
					Spacer()
					
					Text("\(frame.words.count) words")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
				.padding(12)
				.background(Color.purple.opacity(0.1))
				.cornerRadius(8)
			}
			.buttonStyle(.plain)
			
			// Frame content
			if isExpanded {
				VStack(spacing: 4) {
					ForEach(Array(frame.words.enumerated()), id: \.element.id) { index, word in
						StackWordRow(word: word, index: index, isInFrame: true)
					}
				}
				.padding(.leading, 8)
				.padding(.vertical, 8)
			}
		}
		.background(
			RoundedRectangle(cornerRadius: 10)
				.stroke(Color.purple.opacity(0.3), lineWidth: 2)
		)
	}
}
