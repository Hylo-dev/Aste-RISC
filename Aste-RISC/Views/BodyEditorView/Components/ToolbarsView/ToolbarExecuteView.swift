//
//  ToolbarView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarExecuteView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
	@EnvironmentObject private var cpu 				  : CPU
	
    @ObservedObject var optionsWrapper: OptionsAssemblerWrapper
	    
    static private let instructionRegex = try! NSRegularExpression(pattern: #"^\s*(?!\.)(?:[A-Za-z_]\w*:)?([A-Za-z]{2,7})\b"#)
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            // Run and stop button
            Button {
                if self.bodyEditorViewModel.isEditorStopped() {
					// Execute Assembly
					let resultAssembling = AssemblerBridge.shared.assemble(
						optionsAsembler: optionsWrapper.opts!
					)
					
					self.bodyEditorViewModel.isOutputVisible = true
										
					if resultAssembling == 0 {
						let opt = optionsWrapper.opts!.pointee
					
						let textStart = Int(opt.text_vaddr)
						let textEnd   = textStart + opt.text_size
						let dataStart = Int(opt.data_vaddr)
						let dataEnd   = dataStart + opt.data_size

						let stackSize = 0x10000 // 64 KB di stack
						let stackTop = max(textEnd, dataEnd) + stackSize

						let ramBase = min(textStart, dataStart)
						let ramSize = stackTop - ramBase

						self.cpu.ram = new_ram(ramSize, UInt32(ramBase))
						
						load_binary_to_ram(cpu.ram, opt.data_data, opt.data_size, opt.data_vaddr)
						load_binary_to_ram(cpu.ram, opt.text_data, opt.text_size, opt.text_vaddr)
						
						self.cpu.textBase = opt.text_vaddr
						self.cpu.textSize = UInt32(opt.text_size)
						self.cpu.dataBase = opt.data_vaddr
						self.cpu.dataSize = UInt32(opt.data_size)

						self.cpu.loadEntryPoint(value: opt.entry_point)

						self.cpu.registers[2] = Int(stackTop - 4)
					}
					
                    getIndexSourceAssembly()
                    
                    withAnimation { self.bodyEditorViewModel.changeEditorState(.running) }
                    
                } else {
                    withAnimation {
                        self.bodyEditorViewModel.changeEditorState(.stopped)
                        self.bodyEditorViewModel.changeCurrentInstruction(index: nil)
                    }
                    
                }
                
            } label: {
                Image(systemName: self.bodyEditorViewModel.isEditorStopped() ? "play" : "stop.fill")
                    .font(.system(size: 17))
                
            }
            .frame(width: 35, height: 35)
            .buttonStyle(.glass)
			.disabled(optionsWrapper.opts == nil)

            if self.bodyEditorViewModel.editorState == .running {
                GlassEffectContainer(spacing: 30) {
                    HStack(spacing: 10) {
                        Button {
                            let _ = cpu.runStep(optionsSource: optionsWrapper.opts!.pointee)
                            
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                            
                        }
                        .frame(width: 35, height: 35)
                        .buttonStyle(.glass)

                        Button {
                            let _ = cpu.runStep(optionsSource: optionsWrapper.opts!.pointee)
                            
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                        }
                        .frame(width: 35, height: 35)
                        .buttonStyle(.glass)
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
            } else {
                Color.clear
                    .frame(width: 80.0, height: 35.0)
                    .allowsHitTesting(false)
            }
        }
        .animation(.spring(), value: self.bodyEditorViewModel.editorState)
        
    }
    
    private func getIndexSourceAssembly() {
        self.bodyEditorViewModel.cleanInstructionsMapped()
        
        let fileOpen    = self.bodyEditorViewModel.currentFileSelected!
        let fileContent = (try? String(contentsOf: fileOpen, encoding: .utf8)) ?? ""
        
        var controlTextSection = false

        for (index, line) in fileContent.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            if line.contains(".text") { controlTextSection = true; continue }
            if !controlTextSection { continue }
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if Self.instructionRegex.firstMatch(in: String(line), options: [], range: range) != nil {
                self.bodyEditorViewModel.appendInstruction(index)
            }
        }
    }
}
