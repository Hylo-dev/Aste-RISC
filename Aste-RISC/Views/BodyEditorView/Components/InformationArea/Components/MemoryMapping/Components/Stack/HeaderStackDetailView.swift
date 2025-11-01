//
//  HeaderStackDetailView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/11/25.
//

import SwiftUI

struct HeaderStackDetailView: View {
	let activeFrames: Int
	let freeSpace	: UInt32
	let stackPointer: Int
	let framePointer: Int
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Stack")
					.font(.title2)
					.foregroundStyle(.purple)
					.fontWeight(.bold)
				
				Text("\(self.activeFrames) Active frame's")
					.font(.caption)
					.foregroundColor(.secondary)
				
				Text("Space: \(formatSize(self.freeSpace))")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text("SP: 0x\(String(format: "%08x", self.stackPointer))") // registers[2]
					.font(.caption)
					.monospacedDigit()
				
				Text("FP: 0x\(String(format: "%08x", self.framePointer))") // registers[8]
					.font(.caption)
					.monospacedDigit()
					.foregroundColor(.purple)
			}
		}
		.padding()
	}
	
	private func formatSize(_ size: UInt32) -> String {
		if size < 1024 {
			return "\(size)B"
			
		} else if size < 1024 * 1024 {
			return String(format: "%.1fKB", Double(size) / 1024.0)
			
		} else {
			return String(format: "%.1fMB", Double(size) / (1024.0 * 1024.0))
		}
	}
}
