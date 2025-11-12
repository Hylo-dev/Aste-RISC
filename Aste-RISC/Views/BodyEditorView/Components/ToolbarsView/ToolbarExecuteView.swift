//
//  ToolbarView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarExecuteView: View {
	
	/// Use CPU enviroment instance, for manage and use
	/// global state CPU for not overriding the data when
	/// cpu is running.
	@EnvironmentObject
	private var cpu: CPU
		
	/// Use body view model and globals data.
	@ObservedObject
	var viewModel: BodyEditorViewModel
	
	/// Mapping in dictionary the source line inde
	/// to index calculed using the program counter
	/// and ram virtual base address
	@Binding
	var mapInstruction: MapInstructions
	    
	/// Static regex, create when use the instance
	/// to principal view (body view)
    static private let instructionRegex = try! NSRegularExpression(
		pattern: #"^\s*(?!\.)(?:[A-Za-z_]\w*:)?([A-Za-z]{2,7})\b"#
	)
    
    var body: some View {
		
		// Using this for manage the visual glass morphism
		// when buttons appearing
		GlassEffectContainer(spacing: 13) {
			
			HStack(spacing: 10) {
				
				// MARK: - Run | Stop Button
				Button {
								
					// Control if the editor is stoped and run select file code
					if isEditorStopped() {
						runCode()
						
					} else { // If editor is runnig code then stop it
						withAnimation {
							self.viewModel.editorState 		     = .stopped
							self.mapInstruction.indexInstruction = nil
							
							// Set reset state to true
							// This clear all value registers
							// And set the CPU redy for new runing
							self.cpu.resetCpu()
						}
					}
					
				} label: {
					Image(systemName: isEditorStopped() ? "play" : "stop.fill")
						.font(.caption)
					
				}
				// When editor is stopped add run shortcut
				.if(isEditorStopped(), transform: { view in
					view.keyboardShortcut("r", modifiers: .command)
				})
				// When editor is stopped add stop shortcut
				.if(!isEditorStopped(), transform: { view in
					view.keyboardShortcut(".", modifiers: .command)
				})
				.glassEffect(in: .circle)
				.disabled(self.viewModel.optionsWrapper.opts == nil)

				// MARK: FW & BW Button
				// They appear when editor is running code
				if self.viewModel.editorState == .running {
					
					HStack(spacing: 2) {
						
						// Backward button
						Button {
							
							// If cronology is empty, appear message on terminal
							if !self.cpu.backwardExecute() {
								print(
									"Cronology is empty. Not possible execute backward instruction."
								)
							}
							
						} label: {
							Image(systemName: "backward.fill")
								.font(.caption)
							
						}
						.keyboardShortcut("p", modifiers: .command)
						.glassEffect(in: .circle)
						.disabled(self.cpu.historyStack.isEmpty || self.cpu.resetFlag)

						// Forward button
						Button {
							// Run step by step all instruction on source file
							let result = self.cpu.runStep(
								optionsSource: self.viewModel.optionsWrapper.opts!.pointee
							)
							
							// Print run result
							if result != .success { print(result.rawValue) }
							
						} label: {
							Image(systemName: "forward.fill")
								.font(.caption)
						}
						.keyboardShortcut("n", modifiers: .command)
						.glassEffect(in: .circle)
						.disabled(self.cpu.resetFlag)
						
					}
					.transition(.move(edge: .leading).combined(with: .opacity))
					
				} else {
					Color.clear
						.frame(width: 80.0, height: 35.0)
						.allowsHitTesting(false)
				}
				
			}
			.animation(.spring(), value: self.viewModel.editorState)
			
		}
    }
	
	/// Control if editor state is stopped or running
	private func isEditorStopped() -> Bool {
		return self.viewModel.editorState == .readyToBuild ||
			   self.viewModel.editorState == .stopped
	}
	
	/// Set attribute for cpu, if is all set,
	/// running each instruction
	private func runCode() {
		
		// WARNING, THIS CONTROL IS A PRIORITY
		// Because if this var is true, not run the code
		self.cpu.resetFlag = false
		
		// Execute Assembly code
		let resultAssembling = AssemblerBridge.shared.assemble(
			optionsAsembler: self.viewModel.optionsWrapper.opts!
		)
					
		// Execute code when the assembling is correct
		if resultAssembling == 0 {
			
			// Set visibility output
			self.viewModel.isOutputVisible = true
			
			// Get options struct
			let opt = self.viewModel.optionsWrapper.opts!.pointee
		
			// Calc all ram virtual address
			let textStart = Int(opt.text_vaddr)
			let textEnd   = textStart + opt.text_size
			let dataStart = Int(opt.data_vaddr)
			let dataEnd   = dataStart + opt.data_size

			// Set a offset ram, this garanted the ram size
			// to run the program
			let stackSize = 0x10000 // 64KB stack
			
			// Set the top of stack
			let stackTop = max(textEnd, dataEnd) + stackSize

			// Set ram size
			let ramBase = min(textStart, dataStart)
			let ramSize = stackTop - ramBase

			// Instance ram for program
			self.cpu.ram = new_ram(ramSize, UInt32(ramBase))
			
			// Load binary on ram, this is REQUIRED, because the program
			// counter is a pointer to ram
			load_binary_to_ram(cpu.ram, opt.data_data, opt.data_size, opt.data_vaddr)
			load_binary_to_ram(cpu.ram, opt.text_data, opt.text_size, opt.text_vaddr)
			
			// Set offset's ram to CPU
			self.cpu.textBase = opt.text_vaddr
			self.cpu.textSize = UInt32(opt.text_size)
			self.cpu.dataBase = opt.data_vaddr
			self.cpu.dataSize = UInt32(opt.data_size)

			// Get program entry point
			self.cpu.loadEntryPoint(value: opt.entry_point)

			// Set the 'stack pointer' into top stack
			// bocause in RV the stack it grows upwards
			self.cpu.registers[2] = Int(stackTop - 4)
		}
		
		// Init map program counter to line index source code
		getIndexSourceAssembly()
		
		// Start animation
		withAnimation { self.viewModel.editorState = .running }
	}
    
    private func getIndexSourceAssembly() {
		self.mapInstruction.indexesInstructions.removeAll()
        
		let fileOpen    = self.viewModel.fileSelected!
        let fileContent = (try? String(contentsOf: fileOpen, encoding: .utf8)) ?? ""
        
        var controlTextSection = false

        for (index, line) in fileContent.split(
			separator: "\n",
			omittingEmptySubsequences: false
		).enumerated() {
            if line.contains(".text") { controlTextSection = true; continue }
            if !controlTextSection { continue }
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if Self.instructionRegex.firstMatch(in: String(line), options: [], range: range) != nil {
				self.mapInstruction.indexesInstructions.append(index)
            }
        }
    }
}
