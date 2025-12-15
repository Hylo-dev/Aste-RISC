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
	@ObservedObject
	private var cpu: CPU
		
	/// Use body view model and globals data.
	@ObservedObject
	private var viewModel: BodyEditorViewModel
	
	/// Mapping in dictionary the source line inde
	/// to index calculed using the program counter
	/// and ram virtual base address
	@Binding
	private var mapInstruction: MapInstructions
	    
	/// Static regex, create when use the instance
	/// to principal view (body view)
    static private let instructionRegex = try! NSRegularExpression(
		pattern: #"^\s*(?!\.)(?:[A-Za-z_]\w*:)?([A-Za-z]{2,7})\b"#
	)
	
	init(
		cpu			  : CPU,
		viewModel	  : BodyEditorViewModel,
		mapInstruction: Binding<MapInstructions>
	) {
		self.cpu 			 = cpu
		self.viewModel		 = viewModel
		self._mapInstruction = mapInstruction
	}
    
    var body: some View {
		
		// Using this for manage the visual glass morphism
		// when buttons appearing
		GlassEffectContainer(spacing: 13) {
			
			HStack(spacing: 10) {
				let stateEditor = self.viewModel.handleisReady()
				
				// Run | Stop Button
				executionButton(stateEditor)
				

				// FW & BW Button
				// They appear when editor is running code
				if self.viewModel.editorState == .running {
					stepsExecutionBody()
					
				} else {
					Color.clear
						.frame(width: 80.0, height: 35.0)
						.allowsHitTesting(false)
				}
				
			}
			.animation(.spring(), value: self.viewModel.editorState)
		}
    }
	
	// MARK: - Views
	
	@ViewBuilder
	private func executionButton(_ stateEditor: Bool) -> some View {
		Button {
			handleExecution(stateEditor)
			
		} label: {
			Image(systemName: stateEditor ? "play" : "stop.fill")
				.font(.caption)
			
		}
		// When editor is stopped add run shortcut
		.if(stateEditor, transform: { view in
			view.keyboardShortcut("r", modifiers: .command)
		})
		// When editor is stopped add stop shortcut
		.if(!stateEditor, transform: { view in
			view.keyboardShortcut(".", modifiers: .command)
		})
		.glassEffect(in: .circle)
		.disabled(self.viewModel.optionsWrapper.opts == nil)

	}
	
	@ViewBuilder
	private func stepsExecutionBody() -> some View {
		HStack(spacing: 2) {
			backwardButton

			forwardButton
		}
		.transition(.move(edge: .leading).combined(with: .opacity))
	}
	
	/// Manage the backward button execution
	private var backwardButton: some View {
		Button {
			
			// If cronology is empty,
			// appear message on terminal
			self.cpu.backwardExecute()
			
		} label: {
			Image(systemName: "backward.fill")
				.font(.caption)
			
		}
		.keyboardShortcut("p", modifiers: .command)
		.glassEffect(in: .circle)
		.disabled(self.cpu.historyStack.isEmpty || self.cpu.resetFlag)
	}
	
	/// Manage the forward button execution
	private var forwardButton: some View {
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

	// MARK: - Handlers
	
	@inline(__always)
	private func handleExecution(_ stateEditor: Bool) {
		// Control if the editor is stoped and run select file code
		if stateEditor {
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
			let ramBase = 0
			let ramSize = stackTop

			// Instance ram for program
			self.cpu.ram = new_ram(ramSize, UInt32(ramBase))
            
            print("Text Range: 0x\(String(opt.text_vaddr, radix: 16)) - 0x\(String(opt.text_vaddr + UInt32(opt.text_size), radix: 16))")
            print("Data Range: 0x\(String(opt.data_vaddr, radix: 16)) - 0x\(String(opt.data_vaddr + UInt32(opt.data_size), radix: 16))")
            print("Il codice sta accedendo a: 0x4220")
			
			// Load binary on ram, this is REQUIRED, because the program
			// counter is a pointer to ram
			load_binary_to_ram(
				cpu.ram,
				opt.data_data,
				opt.data_size,
				opt.data_vaddr
			)
			
			load_binary_to_ram(
				cpu.ram,
				opt.text_data,
				opt.text_size,
				opt.text_vaddr
			)
			
			load_text_information(
				cpu.ram,
				opt.text_vaddr,
				UInt32(opt.text_size)
			)
			
			load_data_information(
				cpu.ram,
				opt.data_vaddr,
				UInt32(opt.data_size)
			)
		
			// Get program entry point
			self.cpu.loadEntryPoint(value: opt.entry_point)

			self.cpu.registers[2] = Int(stackTop - 4)
            let globalPointer = Int(opt.data_vaddr) + 0x800
            self.cpu.registers[3] = globalPointer
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
