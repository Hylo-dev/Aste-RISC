//
//  StackWordRow.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

// Vista per una singola word nello stack
struct StackWordRow: View {
	
	let stackFrame : StackFrame
	let stackStores: [UInt32: Int]
	let index	   : Int
	let isInFrame  : Bool
	
	var body: some View {
		HStack(spacing: 8) {
			// Indicatore visuale
			Circle()
				.fill(self.stackFrame.color)
				.frame(width: 8, height: 8)
			
			// Offset
			Text("SP+\(self.stackFrame.offsetFromSP * 4)")
				.font(.caption2)
				.foregroundColor(.secondary)
				.frame(width: 50, alignment: .leading)
				.monospacedDigit()
			
			// Indirizzo
			Text(self.stackFrame.label)
				.font(.caption2)
				.monospacedDigit()
				.foregroundColor(.secondary)
				.frame(width: 90, alignment: .leading)
			
			// Tipo di dato
			HStack(spacing: 4) {
				if self.stackFrame.isError {
					Label("ERR", systemImage: "exclamationmark.triangle")
						.font(.caption2)
						.foregroundColor(.red)
					
				} else if self.stackFrame.isFrameBoundary && self.stackFrame.isPointer {
					Label("RA", systemImage: "arrow.turn.up.right")
						.font(.caption2)
						.foregroundColor(.orange)
					
				} else if self.stackFrame.isPointer {
					Label("PTR", systemImage: "arrow.right")
						.font(.caption2)
						.foregroundColor(.blue)
					
				} else if self.stackFrame.isNonZero {
					
					// Set label reginter saved
					let label = identifyWordType(self.stackFrame, index: index)
					Text(label)
						.font(.caption2)
						.foregroundColor(.secondary)
					
				} else {
					Text("0")
						.font(.caption2)
						.foregroundColor(.secondary)
					
				}
			}
			.frame(alignment: .leading)
			
			Spacer()
			
			// Value store memory
			if !self.stackFrame.isError {
				VStack(alignment: .trailing, spacing: 2) {
					Text(String(format: "0x%08x", UInt32(bitPattern: self.stackFrame.value)))
						.font(.caption2)
						.lineLimit(1)
						.monospacedDigit()
					
					Text("\(self.stackFrame.value)")
						.lineLimit(1)
						.font(.caption2)
						.foregroundColor(.secondary)
						.monospacedDigit()
				}
			}
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(isInFrame ? .clear : .gray)
		.cornerRadius(4)
	}
	
	private func identifyWordType(_ stackFrame: StackFrame, index: Int) -> String {

		if let registerNum = stackStores[stackFrame.address] {
			return riscvRegisters.first(
				where: { $0.registerDetail!.number == registerNum && !$0.label.contains("x")}
				
			)?.label ?? "x\(registerNum)"
		}
		
		if index == 0 && stackFrame.isFrameBoundary { return "ra" }
		
		if stackFrame.isNonZero { return "local" }
		
		return "data"
	}
}
