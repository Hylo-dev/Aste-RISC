//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI
import AppKit

struct BodyEditorViem: View {
    
    @Environment(\.openWindow) private var openWindow
    
    // Application state, contains all view models
    @EnvironmentObject private var appState: AppState // TODO -> Add manage CPU view model
    
    @State private var searchFile  : Bool         // Searching File
    @State private var editorStatus: EditorStatus // Runnig section
    @State private var selectedFile: URL?         // Tree file section
    
    // RISC-V CPU Emulator
    @StateObject private var cpu: CPU = CPU(ram: new_ram(Int(DEFAULT_RAM_SIZE))) // Init virtual RAM for RISC-V Code
    
    // C Strucs for emulator management
    @State private var opts: UnsafeMutablePointer<options_t>?
    
    // Current instruction and map index
    @State private var indexInstruction   : UInt32?
    @State private var indexesInstructions: [Int] = []
        
    init() {
        self.editorStatus  = .readyToBuild
        self.searchFile    = false
        self._selectedFile = State(initialValue: nil)
        self.opts          = nil
        
    }

    var body: some View {
        
        NavigationSplitView() {
            treeSection   // Show tree directory
                        
        } content: {
            editorContent // Principal content editor, code editor and show run section
                
        } detail: {
            // More information, for example Stack, table registers
            VStack { Text("Test") }
            
        }
        .onAppear { self.indexInstruction = cpu.programCounter }
        .onChange(of: self.cpu.programCounter, { _, newValue in
            self.indexInstruction = (newValue - opts!.pointee.text_vaddr) / 4
        })
        .onChange(of: selectedFile, { _, newValue in
            if newValue != nil {
                selectedFile!.path.withCString { cUrl in
                    self.opts = start_options(UnsafeMutablePointer(mutating: cUrl))
                    
                    // load program in ram
                    load_binary_to_ram(cpu.ram, opts!.pointee.data_data, opts!.pointee.data_size, opts!.pointee.data_vaddr)
                    load_binary_to_ram(cpu.ram, opts!.pointee.text_data, opts!.pointee.text_size, opts!.pointee.text_vaddr)
                    
                    //self.assemblyData = newAssemblyData(opts).pointee
                }
            }
        })
        .onDisappear {
            withTransaction(Transaction(animation: nil)) {
                appState.setEditorProjectPath(nil)
                appState.navigationState.saveCurrentProjectState(path: "")
            }
            
            Task {
                openWindow(id: "home")
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            
            // Section toolbar, this contains running execution button
            ToolbarItem(placement: .navigation) {
                ToolbarExecuteView(
                    editorStatus       : $editorStatus,
                    selectedFile       : $selectedFile,
                    indexInstruction   : $indexInstruction,
                    indexesInstructions: $indexesInstructions,
                    cpu                : cpu,
                    opts               : opts
                )
            }
            .sharedBackgroundVisibility(.hidden)

            // Center Section for view current file working and search file
            ToolbarItem(placement: .principal) {
                ToolbarStatusView(
                    selectedFile: $selectedFile,
                    editorStatus: $editorStatus
                )
            }
            .sharedBackgroundVisibility(.hidden)
            
            // Search button
            ToolbarItem(placement: .principal) {
                ToolbarSearchView(
                    selectedFile: $selectedFile,
                    searchFile  : $searchFile
                )
                
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    // MARK: Variable show tree directory project
    private var treeSection: some View {
        return VStack {
            DirectoryTreeView(
                rootURL       : URL(fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath),
                currentFile   : $selectedFile
                
            ) { url in
                selectedFile = url
                
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: Show content editor
    private var editorContent: some View {
        let projectPath = URL(fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath)
        let isEmptyPath = selectedFile == nil
        
        return ZStack {
            
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
    }
}

#Preview {
    BodyEditorViem()
}

