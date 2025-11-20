//
//  RowButtonStyle.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/11/25.
//

import SwiftUI

struct RowButtonStyle: ButtonStyle {
	
	/// Control status hovering on button, self set on true when
	/// the cursor is on button content
	@State
	private var isHovering: Bool = false
	
	/// Rapresent if button is focused, the focused state depend on
	/// arrow keyboard.
	let isFocused: Bool?
	
	/// If true then the scaling is active and applied when overing
	/// is true
	let isScalingActive: Bool
	
	/// Set the button corner radius
	let cornerRadius: CGFloat
	
	init(
		scaling		: Bool 	  = true,
		cornerRadius: CGFloat = 26,
		isFocused	: Bool?	  = nil
	) {
		self.isScalingActive = scaling
		self.cornerRadius    = cornerRadius
		self.isFocused	     = isFocused
	}
	
	
	/// Make body button, applied the hovering, scaling and haptic
	/// interaction
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: cornerRadius)
					.fill(backgroundColor())
			)
			.if(self.isScalingActive, transform: { view in
				view.scaleEffect(
					scaleValue(isPressed: configuration.isPressed)
				)
			})
			.onHover { hovering in
				withAnimation(.easeInOut(duration: 0.15)) {
					isHovering = hovering
				}
				
				if self.isScalingActive && hovering {
					NSHapticFeedbackManager.defaultPerformer.perform(
						.alignment,
						performanceTime: .now
					)
				}
			}
	}
	
	// MARK: - Helpers
	
	/// Get the background color button, this change if focused
	/// or hovering is true
	private func backgroundColor() -> Color {
		if let focused = self.isFocused, focused {
			return Color.accentColor.opacity(0.25)
		}
		
		if let focused = self.isFocused, self.isHovering && !focused {
			return Color.primary.opacity(0.18)
		}
		
		return Color.secondary.opacity(0.18)
	}
	
	/// Set the scaling when hovering state change
	private func scaleValue(isPressed: Bool) -> CGFloat {
		if isPressed { return 0.98 }
		return isHovering ? 1.02 : 1.0
	}
}
