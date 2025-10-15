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
    private var mainMemory: RAM
    private var cpu       : CPU
        
    init() {
        self.editorStatus       = .readyToBuild
        
        self.searchFile         = false
        self.treeRefreshTrigger = false
        
        self._selectedFile      = State(initialValue: nil)
        
        self.opts               = nil
        
        self.mainMemory         = new_ram(Int(DEFAULT_RAM_SIZE))
        self.cpu                = CPU(ram: self.mainMemory)
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
//                        compilerProfile: appState.compilerProfile,
                        projectRoot: projectPath,
                        selectedFile: selectedFile!
                    )
                    
                }
            }
                
        } detail: {
            VStack {
                Text("Test")
            }
        }
        .onChange(of: selectedFile, { _, newValue in
            if newValue != nil {
                selectedFile!.path.withCString { cUrl in
                    self.opts = start_options(UnsafeMutablePointer(mutating: cUrl))
                    
                    load_binary_to_ram(mainMemory, opts!.pointee.data_data, opts!.pointee.data_size, opts!.pointee.data_vaddr)
                    load_binary_to_ram(mainMemory, opts!.pointee.text_data, opts!.pointee.text_size, opts!.pointee.text_vaddr)
                    
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
                
                GlassEffectContainer(spacing: 35) {
                    
                    HStack(spacing: 7.0) {
                        Button {
                            let _ = cpu.runStep(
                                optionsSource: opts!.pointee,
                                assemblyData: assemblyData!,
                                mainMemory: mainMemory
                            ) ? "true" : "false"
                            
                            withAnimation(.spring()) {
                                if editorStatus == .readyToBuild || editorStatus == .stopped{
                                    
                                    editorStatus = .building
                                    
                                }
                                
                            }
                            
                        } label: {
                            Image(systemName: "play")
                                .font(.system(size: 17))
                            
                        }
                        .frame(width: 35.0, height: 35.0)
                        .buttonStyle(.glass)
                        
                        if editorStatus != .readyToBuild && editorStatus != .stopped {
                            
                            Button {
                                withAnimation(.spring()) {
                                    
                                    if editorStatus != .readyToBuild || editorStatus != .stopped {
                                        
                                        editorStatus = .stopped
                                        
                                    }
                                    
                                }
                                
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 17))
                                
                            }
                            .frame(width: 35.0, height: 35.0)
                            .buttonStyle(.glass)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        } else {
                            Color.clear
                                .frame(width: 35.0, height: 35.0)
                                .allowsHitTesting(false)
                            
                        }
                    }
                    .animation(.spring(), value: editorStatus)
                }
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
}

#Preview {
    EditorView()
}

