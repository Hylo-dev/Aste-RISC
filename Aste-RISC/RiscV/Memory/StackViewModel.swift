//
//  StackViewModel.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 03/11/25.
//

import SwiftUI
internal import Combine

/// An object that observes a `CPU` instance and transforms its raw stack
/// memory into UI-ready data structures.
///
/// This ViewModel is responsible for the critical performance optimization
/// of decoupling the high-speed CPU simulation from the slower UI updates.
/// It subscribes to CPU state changes (`registers`, `programCounter`),
/// throttles them to a reasonable rate (e.g., 100ms), and then performs
/// the work of reading and parsing the stack.
///
/// It publishes two key arrays for the UI:
/// 1.  `stackFrames`: A "raw" list of 4-byte words read from the stack,
///     enriched with metadata like colors and labels.
/// 2.  `callFrames`: A "logical" list of parsed function call frames,
///     derived from the `stackFrames`.
@MainActor
class StackViewModel: ObservableObject {
	
	/// The "raw" list of stack words (memory addresses and values) read
	/// from the stack pointer, enriched with UI-specific metadata like
	/// colors, labels, and type analysis (e.g., `isPointer`).
	@Published
	var stackFrames: [StackFrame] = []
	
	/// The logical list of parsed `CallFrame` objects.
	/// This array is derived from `stackFrames` by `parseCallFrames`.
	@Published
	var callFrames: [CallFrame] = []
	
	/// A reference to the core CPU simulation model.
	private var cpu: CPU
	
	/// A set to store Combine subscriptions.
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Internal Throttling State
	
	/// The last known Stack Pointer value, used for throttling updates.
	private var lastSP: UInt32 = 0
	
	/// The last known Frame Pointer value, used for throttling updates.
	private var lastFP: UInt32 = 0
	
	/// A counter to force updates every N calls, even if SP/FP are stable.
	private var stackUpdateCounter: Int = 0
	
	/// Creates the StackViewModel.
	///
	/// - Parameter cpu: The `CPU` instance to observe.
	init(cpu: CPU) {
		self.cpu = cpu
	
		// Set up a Combine pipeline to observe the CPU.
		// We merge changes from registers (for SP/FP) and the PC.
		Publishers.Merge(
			cpu.$registers.map { _ in () },      // We only care *that* it changed
			cpu.$programCounter.map { _ in () } // not what the new value is.
		)
		// Throttle updates to prevent UI churn during rapid execution.
		.throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
		// When a throttled update comes through, call our main work function.
		.sink { [weak self] _ in self?.updateStackFrames() }
		.store(in: &cancellables)
	}
	
	/// The main work function, called on a throttled basis by the Combine sink.
	///
	/// This function reads the raw stack memory from the CPU, analyzes each
	/// 4-byte word to create the `stackFrames` array, and then calls
	/// `parseCallFrames` to build the logical `callFrames`.
	///
	/// It contains its own throttling logic to avoid re-calculating the stack
	/// if the Stack Pointer and Frame Pointer have not moved significantly.
	func updateStackFrames() {
		guard let ram = cpu.ram else { return }
		
		let sp = UInt32(cpu.registers[2]) // x2 = Stack Pointer
		let fp = UInt32(cpu.registers[8]) // x8 = Frame Pointer
		
		// --- Internal Throttling ---
		// Only update if SP/FP changed, or if 2 cycles have passed.
		stackUpdateCounter += 1
		let spChanged = abs(Int(sp) - Int(lastSP)) >= 4 // 1-word change
		let fpChanged = fp != lastFP
		
		guard stackUpdateCounter >= 2 || spChanged || fpChanged else {
			return // No significant change, skip update.
		}
		
		stackUpdateCounter = 0
		lastSP = sp
		lastFP = fp
				
		var frames: [StackFrame] = []
		let wordsToShow = 128
		var consecutiveErrors = 0
		let maxConsecutiveErrors = 8 // Stop if we read too much invalid memory
		
		let ramStart = ram.pointee.base_vaddr
		let ramEnd = ramStart + UInt32(ram.pointee.size)

		// --- Stack Walk ---
		// Iterate N words down from the stack pointer (sp)
		for i in 0..<wordsToShow {
			let addr = sp &+ UInt32(i * 4)
			
			// Check memory bounds
			if addr < ramStart || addr + 4 > ramEnd {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
				continue
			}
			
			let rawInstruction = read_ram32bit(ram, addr)
			
			// --- Analysis ---
			let isError = (rawInstruction == -1)
			let isNonZero = (!isError && rawInstruction != 0)
			let rawInstructionUnsigned = UInt32(bitPattern: rawInstruction)
			
			let isPointerToText = (
				rawInstructionUnsigned >= self.cpu.textBase &&
				rawInstructionUnsigned < self.cpu.textBase &+ self.cpu.textSize
			)
			
			let isFrameBoundary = isPointerToText && isNonZero
			let isFramePointer = (addr == fp)
			let isSavedRegister = isNonZero && !isPointerToText && i < 32

			if isError {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
			} else {
				consecutiveErrors = 0
			}

			// --- UI-Data Assignment ---
			// Assign colors based on analysis. This is why this is a ViewModel.
			let color: Color
			if isError {
				color = Color(.systemGray)
			} else if isFramePointer {
				color = Color(.systemPurple).opacity(0.85)
			} else if isFrameBoundary {
				color = Color(.systemRed).opacity(0.85)
			} else if isSavedRegister {
				color = Color(.systemOrange).opacity(0.6)
			} else if isNonZero {
				color = Color(.systemBlue).opacity(0.6)
			} else {
				color = Color(.systemMint)
			}

			// Create the "raw" frame object
			let frame = StackFrame(
				address: addr, value: rawInstruction, color: color,
				label: String(format: "0x%08x", addr),
				isPointer: isPointerToText, isNonZero: isNonZero,
				isError: isError, isFrameBoundary: isFrameBoundary,
				offsetFromSP: i
			)
			frames.append(frame)
		}

		// --- Second-Level Parse ---
		// Now, parse the raw frames into logical call frames
		let newCallFrames = self.parseCallFrames(from: frames)

		// --- Final UI Update ---
		// Animate the changes for a smooth visual transition.
		let animationStyle: Animation = frames.count == self.stackFrames.count ?
				.easeInOut(duration: 0.15) :
				.spring(response: 0.3, dampingFraction: 0.8)
				
		withAnimation(animationStyle) {
			self.stackFrames = frames
			self.callFrames = newCallFrames
		}
	}
	
	/// Parses a raw list of `StackFrame` words into logical `CallFrame` objects.
	///
	/// This function iterates through the `stackFrames` array and groups them
	/// into `CallFrame`s by detecting "frame boundaries." A boundary is
	/// identified by finding a value that is a pointer to the text section
	/// (assumed to be a saved Return Address).
	///
	/// - Parameter stackFrames: The raw list of `StackFrame`s to parse.
	/// - Returns: An array of logical `CallFrame`s.
	private func parseCallFrames(from stackFrames: [StackFrame]) -> [CallFrame] {
		guard !stackFrames.isEmpty else { return [] }
			
		var frames           : [CallFrame]  = []
		var currentFrameWords: [StackFrame] = []
		var frameStart       : UInt32?
		var returnAddr       : UInt32?
		var savedFP          : UInt32?
			
		for word in stackFrames {
			
			// A word pointing to the text section marks the start of a new frame
			// (it's the return address).
			if word.isFrameBoundary && word.isPointer {
				// If we were in a previous frame, save it first.
				if !currentFrameWords.isEmpty, let start = frameStart {
					let size = UInt32(currentFrameWords.count * 4)
					frames.append(
						CallFrame(
							startAddress : start,
							size         : size,
							returnAddress: returnAddr,
							savedFP      : savedFP,
							words        : currentFrameWords
						)
					)
				}
					
				// Start the new frame
				frameStart        = word.address
				returnAddr        = UInt32(bitPattern: word.value)
				savedFP           = nil // Reset saved FP search
				currentFrameWords = [word] // Start new word list
					
			} else {
				// Not a boundary, so just add to the current frame.
				currentFrameWords.append(word)
				
				// Try to find the saved Frame Pointer (s0)
				if savedFP == nil && !word.isError && word.isNonZero && !word.isPointer {
					savedFP = UInt32(bitPattern: word.value)
				}
				
				// Ensure the very first frame has a start address
				if frameStart == nil { frameStart = word.address }
			}
		}
			
		// After the loop, save the last frame being processed.
		if !currentFrameWords.isEmpty, let start = frameStart {
			let size = UInt32(currentFrameWords.count * 4)
			frames.append(
				CallFrame(
					startAddress : start,
					size         : size,
					returnAddress: returnAddr,
					savedFP      : savedFP,
					words        : currentFrameWords
				)
			)
		}
		
		return frames
	}
}
