//
//  ModeButton.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

/// The view show the button for each IDE modality
struct MenuButtonView: View {
	let currentMode: ModalityItem

	var body: some View {
		Button(action: currentMode.function) {
			
			HStack(spacing: 12) {
				
				Image(systemName: currentMode.icon)
					.font(.title2)
					.foregroundStyle(.tint)
					.frame(width: 45, height: 45)
					.background(
						.primary.opacity(0.18),
						in: RoundedRectangle(cornerRadius: 26)
					)
				
				VStack(alignment: .leading, spacing: 2) {
					Text(currentMode.name)
						.font(.headline)
						.foregroundStyle(.primary)
					
					Text(currentMode.description)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}
		}
		.buttonStyle(RowButtonStyle())
	}
}
