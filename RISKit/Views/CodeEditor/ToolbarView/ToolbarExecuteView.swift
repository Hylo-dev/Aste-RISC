//
//  ToolbarView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarExecuteView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    
    @Binding var mapInstruction: MapInstructions
             var cpu           : CPU
             var opts          : UnsafeMutablePointer<options_t>?
    
    static private let instructionRegex = try! NSRegularExpression(pattern: #"^\s*(?!\.)(?:[A-Za-z_]\w*:)?([A-Za-z]{2,7})\b"#)
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            // Run and stop button
            Button {
                if self.bodyEditorViewModel.isEditorStopped() {
                    
                    // Load entry point and setup register
                    self.cpu.loadEntryPoint(value: opts!.pointee.entry_point)
                    self.cpu.registers[2] = 0x100000
                    
                    getIndexSourceAssembly()
                    
                    withAnimation { self.bodyEditorViewModel.changeEditorState(.running) }
                    
                } else {
                    withAnimation {
                        self.bodyEditorViewModel.changeEditorState(.stopped)
                        self.mapInstruction.indexInstruction = nil
                    }
                    
                }
                
            } label: {
                Image(systemName: self.bodyEditorViewModel.isEditorStopped() ? "play" : "stop.fill")
                    .font(.system(size: 17))
                
            }
            .frame(width: 35, height: 35)
            .buttonStyle(.glass)
            .disabled(opts == nil)

            if self.bodyEditorViewModel.editorState == .running {
                GlassEffectContainer(spacing: 30) {
                    HStack(spacing: 10) {
                        Button {
                            let _ = cpu.runStep(
                                optionsSource: opts!.pointee,
                                mainMemory   : cpu.ram
                            )
                            
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.title3)
                            
                        }
                        .frame(width: 35, height: 35)
                        .buttonStyle(.glass)

                        Button {
                            let _ = cpu.runStep(
                                optionsSource: opts!.pointee,
                                mainMemory: cpu.ram
                            )
                            
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
        self.mapInstruction.indexesInstructions.removeAll()
        
        let fileOpen    = self.bodyEditorViewModel.currentFileSelected!
        let fileContent = (try? String(contentsOf: fileOpen, encoding: .utf8)) ?? ""
        
        var controlTextSection = false

        for (index, line) in fileContent.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            if line.contains(".text") { controlTextSection = true; continue }
            if !controlTextSection { continue }
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if Self.instructionRegex.firstMatch(in: String(line), options: [], range: range) != nil {
                self.mapInstruction.indexesInstructions.append(index)
            }
        }
    }
}
