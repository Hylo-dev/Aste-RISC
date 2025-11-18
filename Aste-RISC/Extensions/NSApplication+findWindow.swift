//
//  NSApplication+findWindow.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/11/25.
//

import AppKit

extension NSApplication {
	func findWindow(_ id: String) -> NSWindow? {
		windows.first { $0.identifier?.rawValue == id }
	}
}
