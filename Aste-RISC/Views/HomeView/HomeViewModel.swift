//
//  HomeViewModel.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/11/25.
//

internal import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
	
	/// Glow color, this use the app icon color
	@Published
	var glowColor: Color?
	
	/// When the folder is dropped on IDE, this flag is true,
	/// if the dropping is true then open the ASM project on IDE.
	@Published
	var isDropping: Bool
	
	/// Get the app icon and save ther in struct instance,
	/// because not get this `n` times
	let icon = NSApplication.shared.applicationIconImage!
	
	init() {
		self.isDropping = false
		
		Task {
			let nsColor = await computeAverageColor(
				of: self.icon
			)
			
			self.glowColor = Color(nsColor ?? .white)
		}		
	}
}
