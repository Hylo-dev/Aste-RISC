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
	
	let isFocused	: Bool?
	let scaling		: Bool
	let cornerRadius: CGFloat
	
	init(
		scaling		: Bool 	  = true,
		cornerRadius: CGFloat = 26,
		isFocused	: Bool?	  = nil
	) {
		self.scaling 	  = scaling
		self.cornerRadius = cornerRadius
		self.isFocused	  = isFocused
	}
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: cornerRadius)
					.fill(backgroundColor())
			)
			.if(self.scaling, transform: { view in
				view.scaleEffect(
					scaleValue(isPressed: configuration.isPressed)
				)
			})
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
	
	private func backgroundColor() -> Color {
		if let focused = self.isFocused, focused {
			return Color.accentColor.opacity(0.25)
		}
		
		if let focused = self.isFocused, self.isHovering && !focused {
			return Color.primary.opacity(0.18)
		}
		
		return Color.secondary.opacity(0.18)
	}
	
	private func scaleValue(isPressed: Bool) -> CGFloat {
		if isPressed { return 0.98 }
		return isHovering ? 1.02 : 1.0
	}
}
