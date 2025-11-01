//
//  MemoryWordView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct MemoryWordRow: View {
	let address: UInt32
	let value: Int32
	
	var body: some View {
		HStack {
			Text("0x\(String(format: "%08x", address))")
				.font(.caption)
				.monospacedDigit()
				.foregroundColor(.secondary)
			
			Spacer()
			
			if value == -1 {
				Text("ERROR")
					.font(.caption)
					.foregroundColor(.red)
				
			} else {
				VStack(alignment: .trailing, spacing: 2) {
					Text("0x\(String(format: "%08x", UInt32(bitPattern: value)))")
						.font(.caption)
						.monospacedDigit()
					Text("\(value)")
						.font(.caption2)
						.foregroundColor(.secondary)
						.monospacedDigit()
				}
			}
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(value != 0 && value != -1 ? Color.green.opacity(0.1) : Color.clear)
		.cornerRadius(4)
	}
}
