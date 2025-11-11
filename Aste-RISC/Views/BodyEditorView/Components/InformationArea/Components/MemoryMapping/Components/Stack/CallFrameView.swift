//
//  CallFrameView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct CallFrameView: View {
	@Binding
	private var isExpanded: Bool
	
	private let frame	   : CallFrame
	private let stackStores: [UInt32: Int]
	private let frameIndex : Int
	
	private let frameName: String
	
	init(
		frame	   : CallFrame,
		stackStores: [UInt32: Int],
		frameIndex : Int,
		frameName  : String,
		isExpanded : Binding<Bool>
	) {
		self.frame 		 = frame
		self.stackStores = stackStores
		self.frameIndex  = frameIndex
		self.frameName	 = frameName
		self._isExpanded = isExpanded
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Frame header
			headerCell
				//.onAppear { print(nameFrame) }
			
			VStack(spacing: 0) {
				// Frame content
				if isExpanded {
					VStack(spacing: 4) {
						ForEach(frame.words.enumerated(), id: \.element.id) { index, frame in
							StackWordRow(
								stackFrame : frame,
								stackStores: stackStores,
								index	   : index,
								isInFrame  : true
							)
						}
					}
					.padding(.leading, 8)
					.padding(.vertical, 8)
					.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.frame(maxWidth: .infinity)
			.clipped()
			
		}
		.background(
			RoundedRectangle(cornerRadius: 13)
				.stroke(Color.purple.opacity(0.18), lineWidth: 2)
		)
	}
	
	// MARK: - Views
	
	private var headerCell: some View {
		return Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
			HStack {
				Image(systemName: "chevron.right")
					.rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
					.font(.caption)
					.foregroundColor(.secondary)
				
				VStack(alignment: .leading, spacing: 2) {
					HStack {
						Text("Frame: \(frameName)") // frameIndex
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
			.background(Color.purple.opacity(0.08))
			.cornerRadius(10)
			
		}
		.buttonStyle(.plain)
	}
}
