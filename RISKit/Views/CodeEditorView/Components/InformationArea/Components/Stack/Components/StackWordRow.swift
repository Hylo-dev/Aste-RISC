//
//  StackWordRow.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

// Vista per una singola word nello stack
struct StackWordRow: View {
	@EnvironmentObject private var cpu: CPU
	
	let word: StackFrame
	let index: Int
	let isInFrame: Bool
	
	var body: some View {
		HStack(spacing: 8) {
			// Indicatore visuale
			Circle()
				.fill(word.color)
				.frame(width: 8, height: 8)
			
			// Offset
			Text("SP+\(word.offsetFromSP * 4)")
				.font(.caption2)
				.foregroundColor(.secondary)
				.frame(width: 50, alignment: .leading)
				.monospacedDigit()
			
			// Indirizzo
			Text(word.label)
				.font(.caption2)
				.monospacedDigit()
				.foregroundColor(.secondary)
				.frame(width: 90, alignment: .leading)
			
			// Tipo di dato
			HStack(spacing: 4) {
				if word.isError {
					Label("ERR", systemImage: "exclamationmark.triangle")
						.font(.caption2)
						.foregroundColor(.red)
					
				} else if word.isFrameBoundary && word.isPointer {
					Label("RA", systemImage: "arrow.turn.up.right")
						.font(.caption2)
						.foregroundColor(.orange)
					
				} else if word.isPointer {
					Label("PTR", systemImage: "arrow.right")
						.font(.caption2)
						.foregroundColor(.blue)
					
				} else if word.isNonZero {
					
					// Prova a identificare se è un saved register
					let label = identifyWordType(word, index: index)
					Text(label)
						.font(.caption2)
						.foregroundColor(.secondary)
					
				} else {
					Text("0")
						.font(.caption2)
						.foregroundColor(.secondary)
					
				}
			}
			.frame(width: 60, alignment: .leading)
			
			Spacer()
			
			// Valore
			if !word.isError {
				VStack(alignment: .trailing, spacing: 2) {
					Text(String(format: "0x%08x", UInt32(bitPattern: word.value)))
						.font(.caption2)
						.monospacedDigit()
					
					Text("\(word.value)")
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
	
	private func identifyWordType(_ word: StackFrame, index: Int) -> String {

		if let registerNum = cpu.stackStores[word.address] {
			return riscvRegisters.first(
				where: { $0.registerDetail!.number == registerNum && !$0.label.contains("x")}
			)?.label ?? "x\(registerNum)"
		}
		
		if index == 0 && word.isFrameBoundary { return "ra" }
		
		if word.isNonZero { return "local" }
		
		return "data"
	}
}
