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
	
	/// Holds the mapping between assembly instructions and their source lines,
	/// primarily to track the currently executing instruction.
	@Published
	var mapInstruction: MapInstructions
	
	/// A reference to the core CPU simulation model.
	private var cpu: CPU
	
	/// A set to store Combine subscriptions.
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Internal Throttling State
	
	/// The last known Stack Pointer value, used for throttling updates.
	private var lastSP: UInt32 = 0
	
	/// A counter to force updates every N calls, even if SP/FP are stable.
	private var stackUpdateCounter: Int = 0
	
	/// Creates the StackViewModel.
	///
	/// - Parameter cpu: The `CPU` instance to observe.
	init(cpu: CPU) {
		
		self.mapInstruction = MapInstructions()
		self.cpu 			= cpu
	
		// Set up a Combine pipeline to observe the CPU.
		// We merge changes from registers (for SP/FP) and the PC.
		Publishers.Merge(
			cpu.$registers.map { _ in () },     // We only care that it changed
			cpu.$programCounter.map { _ in () } // not what the new value is.
		)
		// Throttle updates to prevent UI churn during rapid execution.
		.throttle(for: .milliseconds(5), scheduler: RunLoop.main, latest: true)
		// When a throttled update comes through, call our main work function.
		.sink { [weak self] _ in
			
			if !(self?.cpu.resetFlag ?? true) {
				self?.updateStackFrames()
				
			} else {
				withAnimation(.spring()) {
					self?.callFrames.removeAll()
					self?.stackFrames.removeAll()
				}
			}
		}
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
		
		// Only update if SP/FP changed,
		// or if 2 cycles have passed
		stackUpdateCounter += 1
		
		// 1-word is changed
		let spChanged = abs(Int(sp) - Int(lastSP)) >= 4
		
		guard stackUpdateCounter >= 2 || spChanged else {
			return // No significant change, skip update.
		}
		
		// Reset for control frame update
		stackUpdateCounter = 0
		lastSP 			   = sp
				
		var frames: [StackFrame] = []
		let wordsToShow 		 = 128
		var consecutiveErrors 	 = 0
		
		// Stop if we read too much invalid memory
		let maxConsecutiveErrors = 8
		
		// Set limits ram, the virtual address for the start
		// and the ram size + the start for get the end address
		let ramStart = ram.pointee.base_vaddr
		let ramEnd   = ramStart + UInt32(ram.pointee.size)

		// Iterate the stack.
		// This iterate teh stack from top to base,
		// iterated N words down from the stack pointer
		for i in 0 ..< wordsToShow {
			
			// Calc current iterate addres
			// This work because exect the 'and' logic operation
			// on the current index multiplied by 4 to get a word.
			let addr = sp &+ UInt32(i * 4)
			
			// Check memory bounds
			// Control address is in start and end range
			// If true then update errors flag
			if addr < ramStart || addr + 4 > ramEnd {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
				
				continue
			}
			
			// Get value on address in the ram
			let rawInstruction = read_ram32bit(ram, addr)
			
			// MARK: - Analysis the instruction
			
			let isError = rawInstruction == -1
			if isError {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
				
			} else { consecutiveErrors = 0 }
			
			// Contrel if the instruction is not 'zero'
			let isNonZero = (!isError && rawInstruction != 0)
			let rawInstructionUnsigned = UInt32(bitPattern: rawInstruction)
			
			let isPointerToText = (
				rawInstructionUnsigned >= self.cpu.textBase &&
				rawInstructionUnsigned < self.cpu.textBase &+ self.cpu.textSize
			)
			
			let isFrameBoundary = isPointerToText && isNonZero
			let isFramePointer  = (addr == fp)
			let isSavedRegister = isNonZero && !isPointerToText && i < 32

			// MARK: UI-Data Assignment
			// Assign colors based on analysis
			let color = if isError {
				Color(.systemGray)
				
			} else if isFramePointer {
				Color(.systemPurple).opacity(0.85)
				
			} else if isFrameBoundary {
				Color(.systemRed).opacity(0.85)
				
			} else if isSavedRegister {
				Color(.systemOrange).opacity(0.6)
				
			} else if isNonZero {
				Color(.systemBlue).opacity(0.6)
				
			} else {
				Color(.systemMint)
				
			}

			// Create the "raw" frame object
			let frame = StackFrame(
				address		   : addr,
				value		   : rawInstruction,
				color		   : color,
				label		   : String(format: "0x%08x", addr),
				isPointer	   : isPointerToText,
				isNonZero	   : isNonZero,
				isError		   : isError,
				isFrameBoundary: isFrameBoundary,
				offsetFromSP   : i
			)
			
			frames.append(frame)
		}

		// MARK: Second-Level Parse
		// Parse the raw frames into logical call frames
		let newCallFrames = self.parseCallFrames(from: frames)

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
	/// into `CallFrame`s, this catalogue the frames in newest priority, the more
	/// recent frame is first frame on array.
	/// Set the program counter for each frame, it contains jump instruction, usally `jal`
	/// instruction.
	///
	/// - Parameter stackFrames: The raw list of `StackFrame`s to parse.
	/// - Returns: An array of logical `CallFrame`s.
	private func parseCallFrames(from stackFrames: [StackFrame]) -> [CallFrame] {
		guard !stackFrames.isEmpty else { return [] }
				
		var frames 			 : [CallFrame]  = []
		var currentFrameWords: [StackFrame] = []
		var frameStart 		 : UInt32?
		var savedFP			 : UInt32?
				
		// 1 - Create all frame and use program counter placeholder
		// Iterate all StackFrames and create each CallFrame, assign
		// program counter, return address, frame pointer and another
		// metadata
		for word in stackFrames {
			
			// Save frame word on array
			currentFrameWords.append(word)
			if frameStart == nil { frameStart = word.address }
				
			// Search saved frame pointer
			if savedFP == nil && !word.isError && !word.isNonZero && !word.isPointer {
				savedFP = UInt32(bitPattern: word.value)
			}
				
			// Use return address for sign the current end frame
			if word.isFrameBoundary && word.isPointer {
				if let start = frameStart {
					let size = UInt32(currentFrameWords.count * 4)
					let returnAddr = UInt32(bitPattern: word.value)
						
					frames.append(
						CallFrame(
							programCounter: 0, // Placeholder
							startAddress  : start,
							size          : size,
							returnAddress : returnAddr, // This is the RA for the next frame
							savedFP       : savedFP,
							words         : currentFrameWords
						)
					)
				}
					
				// Reset all values for next frame
				frameStart 		  = nil
				savedFP 		  = nil
				currentFrameWords = []
			}
		}
				
		// Save last frame
		// (this is more oldest frame, principaly the entry point frame)
		if !currentFrameWords.isEmpty, let start = frameStart {
			let size = UInt32(currentFrameWords.count * 4)
			
			frames.append(
				CallFrame(
					programCounter: 0,    // Placeholder value
					startAddress  : start,
					size          : size,
					returnAddress : nil,  // Entry point not have a return address
					savedFP       : savedFP,
					words         : currentFrameWords
				)
			)
		}
			
		// 2 - Asign the correct program counter
		//
		// Example use:
		// You have four 'frames': [frame_C, frame_B, frame_A, entry_point]
		// The order is old > new
		if frames.count > 0 {
			
			// First frame "C", get they return address if exist
			// Because, if array frame contains one item: [entry_point]
			// the return address is nil, in this case set 0
			// else, set RA and subtract 4 because get 'jal' instruction
			//frames[0].programCounter = frames[0].returnAddress != nil ?
			//							   frames[0].returnAddress! - 4 : 0
				
				
			// Iterate from the second onwards
			// In this case: [frame_C, frame_B, frame_A, entry_point]
			// Your skip 'C' and continue after 'C'
			for i in 0 ..< frames.count {
				
				// The program counter for this frame (ex. B) is based
				// in they return address
				// Is based in the before return address saved in the
				// after frame (ex. C)
				if let previousFrameRA = frames[i].returnAddress {
					frames[i].programCounter = previousFrameRA - 4
					
				} else {
					
					// If the before frame not have return address,
					// for example the entry point not have a return address because
					// is the prinripal frame loaded.
					// Int this case the program counter use the placeholder, this value
					// is 'zero'. So it covers the entry point case.
					frames[i].programCounter = 0
				}
			}
		}

		return frames
	}
	
	// MARK: - Handles
	
	/// Responds to changes in the CPU's program counter.
	///
	/// Calculates the new instruction index based on the virtual text address
	/// (from `optionsWrapper`) and updates the `mapInstruction` to highlight
	/// the currently executing line in the editor.
	///
	/// - Parameters:
	///   - oldValue: The previous program counter value (unused).
	///   - newValue: The new program counter value.
	func handleProgramCounterChange(
		newValue	  : UInt32,
		optionsWrapper: OptionsAssemblerWrapper
	) {
		guard let opts = optionsWrapper.opts, newValue != 0 else { return }
		
		// Calculate the zero-based instruction index
		self.mapInstruction.indexInstruction = UInt32((newValue - (opts.pointee.text_vaddr)) / 4)
	}
}
