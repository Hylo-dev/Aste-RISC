//
//  RowButtonStyle.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/11/25.
//

import SwiftUI

struct RowButtonStyle: ButtonStyle {
	@State
	private var isHovering: Bool = false
	
	let scaling: Bool
	
	init(scaling: Bool = true) {
		self.scaling = scaling
	}
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: 26)
					.fill(backgroundColor(isPressed: configuration.isPressed))
			)
			.clipShape(RoundedRectangle(cornerRadius: 26))
			.if(self.scaling, transform: { view in
				view.scaleEffect(
					scaleValue(isPressed: configuration.isPressed)
				)
			})
			.contentShape(RoundedRectangle(cornerRadius: 26))
			.onHover { hovering in
				withAnimation(.easeInOut(duration: 0.15)) {
					isHovering = hovering
				}
				
				if self.scaling && hovering {
					NSHapticFeedbackManager.defaultPerformer.perform(
						.alignment,
						performanceTime: .now
					)
				}
			}
	}
	
	// MARK: - Helpers
	
	private func backgroundColor(isPressed: Bool) -> Color {
		if isPressed  { return Color.accentColor.opacity(0.25) }
		if isHovering { return Color.accentColor.opacity(0.18) }
		
		return Color.secondary.opacity(0.18)
	}
	
	private func scaleValue(isPressed: Bool) -> CGFloat {
		if isPressed { return 0.98 }
		return isHovering ? 1.02 : 1.0
	}
}
