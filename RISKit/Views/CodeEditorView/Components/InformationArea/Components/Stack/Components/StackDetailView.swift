//
//  StackDetailView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct StackDetailView: View {
	let section: MemorySection
	@EnvironmentObject var cpu: CPU
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			// Header
			HStack {
				VStack(alignment: .leading) {
					Text("Stack")
						.font(.title2)
						.fontWeight(.bold)
					
					Text("\(detectedFrames.count) frame(s) attivi")
						.font(.caption)
						.foregroundColor(.secondary)
					
					Text("Space: \(formatSize(section.size))")
						.font(.caption)
						.foregroundColor(.secondary)
				}
				
				Spacer()
				
				VStack(alignment: .trailing) {
					Text("SP: 0x\(String(format: "%08x", cpu.registers[2]))")
						.font(.caption)
						.monospacedDigit()
					
					Text("FP: 0x\(String(format: "%08x", cpu.registers[8]))")
						.font(.caption)
						.monospacedDigit()
						.foregroundColor(.purple)
				}
			}
			.padding()
			
			Divider()
			
			// List frame
			if detectedFrames.isEmpty {
				VStack {
					Spacer()
					
					Image(systemName: "tray")
						.font(.system(size: 40))
						.foregroundColor(.secondary)
					
					Text("Empty stack")
						.foregroundColor(.secondary)
					
					Spacer()
				}
				
			} else {
				ForEach(Array(detectedFrames.enumerated()), id: \.element.id) { index, frame in
					CallFrameView(frame: frame, frameIndex: index)
						.padding(.horizontal)
				}
			}
		}
	}
	
	// Rileva i frame analizzando lo stack
	private var detectedFrames: [CallFrame] {
		guard !cpu.stackFrames.isEmpty else { return [] }
		
		var frames: [CallFrame] = []
		var currentFrameWords: [StackFrame] = []
		var frameStart: UInt32?
		var returnAddr: UInt32?
		var savedFP: UInt32?
		
		for word in cpu.stackFrames {
			// Inizia un nuovo frame quando troviamo un return address
			if word.isFrameBoundary && word.isPointer {
				// Salva il frame precedente se esiste
				if !currentFrameWords.isEmpty, let start = frameStart {
					let size = UInt32(currentFrameWords.count * 4)
					frames.append(CallFrame(
						startAddress: start,
						size: size,
						returnAddress: returnAddr,
						savedFP: savedFP,
						words: currentFrameWords
					))
				}
				
				// Inizia nuovo frame
				frameStart = word.address
				returnAddr = UInt32(bitPattern: word.value)
				savedFP = nil
				currentFrameWords = [word]
				
			} else {
				// Aggiungi al frame corrente
				currentFrameWords.append(word)
				
				// Cerca il saved frame pointer (di solito subito dopo il RA)
				if savedFP == nil && !word.isError && word.isNonZero && !word.isPointer {
					savedFP = UInt32(bitPattern: word.value)
				}
				
				// Se non abbiamo ancora un frame, questo è il primo
				if frameStart == nil {
					frameStart = word.address
				}
			}
		}
		
		// Aggiungi l'ultimo frame se esiste
		if !currentFrameWords.isEmpty, let start = frameStart {
			let size = UInt32(currentFrameWords.count * 4)
			frames.append(CallFrame(
				startAddress: start,
				size: size,
				returnAddress: returnAddr,
				savedFP: savedFP,
				words: currentFrameWords
			))
		}
		
		return frames
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
