//
//  RoundedRectangle+If.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/11/25.
//

import SwiftUI

extension RoundedRectangle {
	
	/// Applied the modifier, if the condition is true
	@ViewBuilder
	func `if`<Content: View>(
		_ condition: Bool,
		transform: (Self) -> Content
	) -> some View {
		if condition { transform(self) } else { self }
	}
}
