//
//  StackDetailView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import SwiftUI

/// A view that displays a detailed, interactive representation of the stack.
///
/// This view receives pre-parsed `callFrames` and `stackStores` via bindings,
/// ensuring it remains lightweight and performant. It displays a header
/// (`HeaderStackDetailView`), a list of collapsible frames (`_CallFramesListView`),
/// or an empty state placeholder.
///
/// This view is designed to be "dumb," receiving all its data from parent
/// models (like `StackViewModel` and `CPU`) to avoid expensive calculations
/// within the view body.
struct StackDetailView: View {
	
	/// Enviroment view model for manage nhe stack view's
	@EnvironmentObject
	private var stackViewModel: StackViewModel
	
	/// A binding to the list of detected call frames to display.
	@Binding
	private var callFrames: [CallFrame]
	
	/// A binding to the map of stack addresses and the registers stored there.
	@Binding
	private var stackStores: [UInt32: Int]
	
	/// Internal state tracking which call frames are currently expanded
	/// (identified by their index).
	@State
	private var expandedFrames: Set<Int>
	
	/// Metadata about the stack memory section (e.g., total size).
	private let section: MemorySection
	
	/// The current Stack Pointer (x2) value to display.
	private let stackPointer: Int
	
	/// The current Frame Pointer (x8) value to display.
	private let framePointer: Int
	
	/// Content running file
	private let contentFile: String
	
	private let textVirtualAddress: UInt32
	
	/// Creates the stack detail view.
	///
	/// - Parameters:
	///   - section: Metadata about the stack memory section.
	///   - callFrames: A binding to the pre-parsed list of call frames.
	///   - stackStores: A binding to the map of register values stored on the stack.
	///   - stackPointer: The current value of the SP register.
	///   - framePointer: The current value of the FP register.
	///   - programCounter: The current program counter cpu.
	init(
		section     : MemorySection,
		callFrames  : Binding<[CallFrame]>,
		stackStores : Binding<[UInt32: Int]>,
		stackPointer: Int,
		framePointer: Int,
		contentFile	: String,
		textVirtualAddress: UInt32
	) {
		self.expandedFrames = [0] // Default the first frame to expanded
		self.section        = section
		self._stackStores   = stackStores
		self._callFrames    = callFrames
		self.stackPointer   = stackPointer
		self.framePointer   = framePointer
		self.contentFile 	= contentFile
		self.textVirtualAddress = textVirtualAddress
	}
		
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			headerView
			
			Divider()
			
			if !self.callFrames.isEmpty {
				// The complex list logic is isolated in a private struct
				// to help compiler performance.
				_CallFramesListView(
					callFrames     : self.callFrames,
					stackStores    : self.stackStores,
					contentSplited : self.contentFile.components(separatedBy: .newlines),
					mapInstructions: self.stackViewModel.mapInstruction,
					textVirtualAddress: self.textVirtualAddress,
					expandedFrames : self.$expandedFrames
				)
				.padding(.top, 5)
			}
		}
	}
	
	// MARK: - Views
	
	/// The header view showing summary statistics about the stack.
	private var headerView: some View {
		HeaderStackDetailView(
			activeFrames : self.callFrames.count,
			freeSpace    : self.section.size,
			stackPointer : self.stackPointer,
			framePointer : self.framePointer
		)
	}
}

/// A private helper view that isolates the complex `ForEach` and `Binding` logic
/// from the main `StackDetailView`.
///
/// This separation improves compiler stability and performance by breaking
/// down a complex view body into smaller, independent components.
private struct _CallFramesListView: View {
	let callFrames	   	  : [CallFrame]
	let stackStores	   	  : [UInt32: Int]
	let contentSplited 	  : [String]
	let mapInstructions	  : MapInstructions
	let textVirtualAddress: UInt32
	
	/// Connects to the parent view's state tracking expanded frames.
	@Binding
	var expandedFrames: Set<Int>
	
	var body: some View {
		
		ForEach(callFrames.enumerated(), id: \.element.id) { index, frame in
			
			// Get name for single frame
			let name = if frame.returnAddress == nil {
				self.contentSplited
					.first(where: { row in row.contains(".globl") })
					.flatMap { completeRow in completeRow.split(separator: " ").last }
					.map { lastElement in String(lastElement) }
				?? "_start"
				
			} else {
				self.contentSplited[
					self.mapInstructions.getIndex(
						Int((frame.programCounter - textVirtualAddress) / 4)
					)
				]
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.split(separator: " ")
				.last
				.map(String.init)
				?? "unknown_func"
			}
			
			CallFrameView(
				frame      : frame,
				stackStores: self.stackStores,
				frameIndex : index,
				frameName  : name,
				isExpanded : self.bindingFor(index: index)
			)
			.id(frame.id)
			.padding(.horizontal)
		}
	}
	
	/// Creates a custom, two-way `Binding<Bool>` for a specific frame index.
	///
	/// This allows the `CallFrameView` to control its own expansion state
	/// by modifying the `expandedFrames` `Set` in the parent view.
	///
	/// - Parameter index: The index of the frame in the `callFrames` array.
	/// - Returns: A `Binding<Bool>` that is `true` if the frame is expanded.
	private func bindingFor(index: Int) -> Binding<Bool> {
		Binding(
			get: { expandedFrames.contains(index) },
			set: { newValue in
				if newValue {
					expandedFrames.insert(index)
					
				} else {
					expandedFrames.remove(index)
				}
			}
		)
	}
}
