//
//  TerminalOutputModel.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/10/25.
//

import SwiftUI
import Foundation
internal import Combine

final class TerminalOutputModel: ObservableObject {
	@Published var messages: [assembler_message_t] = []
	
	func append(_ message: assembler_message_t) {
		Task { @MainActor in self.messages.append(message) }
	}
	
	func clear() {
		Task { @MainActor in self.messages.removeAll() }
	}
}

