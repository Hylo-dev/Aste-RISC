//
//  StackDetailView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

struct StackDetailView: View {
	@State private var expandedFrames: Set<Int>
	
	private let section: MemorySection
	private let stackPointer: Int
	private let framePointer: Int
	private let stackFrames : [StackFrame]
	private let stackStores : [UInt32: Int]
	
	init(
		section		: MemorySection,
		stackPointer: Int,
		framePointer: Int,
		stackFrames : [StackFrame],
		stackStores : [UInt32: Int]
	) {
		self.expandedFrames = [0]
		self.section 		= section
		self.stackPointer   = stackPointer
		self.framePointer	= framePointer
		self.stackFrames	= stackFrames
		self.stackStores 	= stackStores
	}
		
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			// Header
			
			HeaderStackDetailView(
				activeFrames: self.detectedFrames.count,
				freeSpace	: self.section.size,
				stackPointer: self.stackPointer,
				framePointer: self.framePointer
			)
			
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
				ForEach(detectedFrames.enumerated(), id: \.element.id) { index, frame in
					CallFrameView(
						frame	   : frame,
						stackStores: stackStores,
						frameIndex : index,
						isExpanded : Binding(
							get: { expandedFrames.contains(index) },
							set: { newValue in
								if newValue {
									expandedFrames.insert(index)
									
								} else {
									expandedFrames.remove(index)
									
								}
							}
						)
					)
					.id(frame.id)
					.padding(.horizontal)
				}
			}
		}
	}
	
	// Rileva i frame analizzando lo stack
	private var detectedFrames: [CallFrame] {
		guard !stackFrames.isEmpty else { return [] }
		
		var frames			 : [CallFrame]  = []
		var currentFrameWords: [StackFrame] = []
		var frameStart		 : UInt32?
		var returnAddr		 : UInt32?
		var savedFP			 : UInt32?
		
		// Iterate all stack frames
		for word in stackFrames {
			
			// Init new frame when found return address
			if word.isFrameBoundary && word.isPointer {
				
				// Save previus frame if exist
				if !currentFrameWords.isEmpty, let start = frameStart {
					let size = UInt32(currentFrameWords.count * 4)
					
					frames.append(
						CallFrame(
							startAddress : start,
							size		 : size,
							returnAddress: returnAddr,
							savedFP		 : savedFP,
							words		 : currentFrameWords
						)
					)
				}
				
				// Init new frame
				frameStart 		  = word.address
				returnAddr 		  = UInt32(bitPattern: word.value)
				savedFP 		  = nil
				currentFrameWords = [word]
				
			} else {
				currentFrameWords.append(word) // Add current frame
				
				// Search saved frame pointer
				if savedFP == nil && !word.isError && word.isNonZero && !word.isPointer {
					savedFP = UInt32(bitPattern: word.value)
				}
				
				// If not have frame, this is first
				if frameStart == nil { frameStart = word.address }
			}
		}
		
		// Add last frame if exist
		if !currentFrameWords.isEmpty, let start = frameStart {
			let size = UInt32(currentFrameWords.count * 4)
			frames.append(
				CallFrame(
					startAddress : start,
					size		 : size,
					returnAddress: returnAddr,
					savedFP		 : savedFP,
					words		 : currentFrameWords
				)
			)
		}
		
		return frames
	}
}
