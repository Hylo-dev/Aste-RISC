//
//  ExtensionColor.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import SwiftUI

extension Color {
	static func randomFrameColor() -> Color {
		let palette: [Color] = [
			.blue.opacity(0.6),
			.green.opacity(0.6),
			.orange.opacity(0.6),
			.purple.opacity(0.6),
			.pink.opacity(0.6),
			.yellow.opacity(0.6)
		]
		
		return palette.randomElement()!
	}
}
