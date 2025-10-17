//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI
import AppKit

struct EditorView: View {
    
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject         private var appState       : AppState
    
    // Searching File
    @State private var searchFile         : Bool
    
    // Runnig section
    @State private var editorStatus       : EditorStatus
    
    // Tree file section
    @State private var treeRefreshTrigger : Bool
    @State private var selectedFile       : URL?
    @State private var columnVisibility   : NavigationSplitViewVisibility = .all
    
    // C Structs
    @State private var opts        : UnsafeMutablePointer<options_t>?
    @State private var assemblyData: AssemblyData?
    
    // Init virtual RAM for RISC-V Code
    @StateObject private var cpu: CPU = CPU(ram: new_ram(Int(DEFAULT_RAM_SIZE)))
    
    // Current instruction and map index
    @State private var indexInstruction   : UInt?
    @State private var indexesInstructions: [Int] = []
    static private let instructionRegex           = try! NSRegularExpression(
        pattern: #"^\s*(?!\.)(?:[A-Za-z_]\w*:)?([A-Za-z]{2,7})\b"#)
        
    init() {
        self.editorStatus       = .readyToBuild
        
        self.searchFile         = false
        self.treeRefreshTrigger = false
        
        self._selectedFile      = State(initialValue: nil)
        
        self.opts               = nil
    }

    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
            VStack {
                DirectoryTreeView(
                    rootURL: URL(fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath),
                    refreshTrigger: treeRefreshTrigger,
                    currentFile: $selectedFile
                    
                ) { url in
                    selectedFile = url
                    
                }
                .onChange(of: editorStatus == .build) { _, newValue in
                    if newValue {
                        treeRefreshTrigger.toggle()
                    }
                }
                
                Spacer()
                
            }
            .padding(.horizontal, 10)
            
            
                                    
        } content: {
            let projectPath = URL(fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath)
            let isEmptyPath = selectedFile == nil
            
            ZStack {
                
                if searchFile || isEmptyPath {
                    
                    FileSearchView(directory: projectPath) { currentFile in
                        selectedFile = currentFile.url
                        searchFile = false
                        
                    }
                    .transition(.opacity)
                    .zIndex(1)
                    
                }
                
                if  !isEmptyPath {
                    ContextView(
                        indexInstruction   : $indexInstruction,
                        indexesInstructions: $indexesInstructions,
                        editorStatus       : $editorStatus,
                        projectRoot        : projectPath,
                        selectedFile       : selectedFile!
                    )
                }
            }
                
        } detail: {
            VStack {
                Text("Test")
            }
        }
        .onAppear(perform: {
            self.indexInstruction = cpu.programCounter
        })
        .onChange(of: self.cpu.programCounter, { _, newValue in
            self.indexInstruction = (newValue - UInt(opts!.pointee.text_vaddr)) / 4
        })
        .onChange(of: selectedFile, { _, newValue in
            if newValue != nil {
                selectedFile!.path.withCString { cUrl in
                    self.opts = start_options(UnsafeMutablePointer(mutating: cUrl))
                    
                    load_binary_to_ram(cpu.ram, opts!.pointee.data_data, opts!.pointee.data_size, opts!.pointee.data_vaddr)
                    load_binary_to_ram(cpu.ram, opts!.pointee.text_data, opts!.pointee.text_size, opts!.pointee.text_vaddr)
                    
                    self.cpu.loadEntryPoint(value: UInt(opts!.pointee.entry_point))
                    self.cpu.registers[2] = 0x100000
                    
                    self.assemblyData = newAssemblyData(opts).pointee
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            withTransaction(Transaction(animation: nil)) {
                appState.setEditorProjectPath(nil)
                appState.navigationState.saveCurrentProjectState(path: "")
            }
            
            Task {
                openWindow(id: "home")
            }
            
        }
        .toolbar {
            
            // Section toolbar, this contains running execution button
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 10) {
                    
                    // Run and stop button
                    Button {
                        if editorStatus == .readyToBuild || editorStatus == .stopped {
                            self.cpu.loadEntryPoint(value: UInt(opts!.pointee.entry_point))
                            self.cpu.registers[2] = 0x100000
                            
                            getIndexSourceAssembly()
                            
                            editorStatus = .running
                            
                        } else {
                            editorStatus = .stopped
                            self.indexInstruction = nil
                            
                        }
                        
                    } label: {
                        Image(systemName: editorStatus == .readyToBuild || editorStatus == .stopped ? "play" : "stop.fill")
                            .font(.system(size: 17))
                        
                    }
                    .frame(width: 35, height: 35)
                    .buttonStyle(.glass)
                    .disabled(opts == nil)

                    if editorStatus == .running {
                        GlassEffectContainer(spacing: 30) {
                            HStack(spacing: 10) {
                                Button {
                                    let _ = cpu.runStep(
                                        optionsSource: opts!.pointee,
                                        mainMemory: cpu.ram
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
                .animation(.spring(), value: editorStatus)
            }
            .sharedBackgroundVisibility(.hidden)

            // Center Section for view current file working and search file
            ToolbarItem(placement: .principal) {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "desktopcomputer")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(appState.navigationState.navigationItem.selectedProjectName)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .layoutPriority(1)
                        
                        if selectedFile != nil {
                            
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            
                            Text(selectedFile!.lastPathComponent)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .layoutPriority(1)
                            
                        }
                        
                    }
                    .layoutPriority(1)
                    
                    Spacer()
                    
                    let projectName = appState.navigationState.navigationItem.selectedProjectName
                    switch editorStatus {
                        case .readyToBuild:
                            Text("\(projectName) is ready to build")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                        case .building:
                            Text("\(projectName) is building")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                        case .build:
                            Text("\(projectName) is build")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                        case .running:
                            Text("\(projectName) is running")
                            .font(.subheadline)
                            .fontWeight(.light)
                        
                        case .stopped:
                            Text("Finished running \(projectName)")
                            .font(.subheadline)
                            .fontWeight(.light)
                            
                    }
                }
                .frame(minWidth: 200, idealWidth: 500)
                .padding(12)
                .glassEffect()
                
            }
            .sharedBackgroundVisibility(.hidden)
            
            ToolbarItem(placement: .principal) {
                
                Button {
                    withAnimation(.spring()) {
                        if selectedFile != nil { searchFile.toggle() }
                        
                    }
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .frame(width: 35, height: 35)
                        .contentShape(Circle())
                    
                }
                .buttonStyle(.plain)
                .glassEffect(in: .circle)
                .clipShape(Circle())
                .padding(.leading, 20)
                
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    private func getIndexSourceAssembly() {
        self.indexesInstructions.removeAll()
        
        let fileContent = (try? String(contentsOf: selectedFile!, encoding: .utf8)) ?? ""
        
        var controlTextSection = false

        for (index, line) in fileContent.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            if line.contains(".text") { controlTextSection = true; continue }
            if !controlTextSection { continue }
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if Self.instructionRegex.firstMatch(in: String(line), options: [], range: range) != nil {
                self.indexesInstructions.append(index)
            }
        }        
    }
}

#Preview {
    EditorView()
}

