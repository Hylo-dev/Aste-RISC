//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI
import AppKit

struct BodyEditorView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    // Application state, contains all global view models
    @EnvironmentObject private var appState: AppState
    
    // ViewModel for manage UI body editor and RISC-V CPU Emulator
    @StateObject private var bodyEditorViewModel = BodyEditorViewModel()
    @StateObject private var cpu                 = CPU(ram: new_ram(Int(DEFAULT_RAM_SIZE)))
    
    // Options emulator and mapping source asm code
    @State private var opts          : UnsafeMutablePointer<options_t>? = nil
    @State private var mapInstruction: MapInstructions                  = MapInstructions()

    var body: some View {
        
        NavigationSplitView() {
            treeSection   // Show tree directory
                        
        } content: {
            editorArea // Principal content editor, code editor and show run section
                
        } detail: {
            // More information, for example Stack, table registers
            VStack { Text("Test") }
            
        }
        .onAppear { self.mapInstruction.indexInstruction = cpu.programCounter }
        .onChange(of: self.cpu.programCounter, { _, newValue in
            self.mapInstruction.indexInstruction = (newValue - opts!.pointee.text_vaddr) / 4
        })
        .onChange(of: self.bodyEditorViewModel.currentFileSelected, { _, newValue in
            if newValue != nil {
                newValue!.path.withCString { cUrl in
                    self.opts = start_options(UnsafeMutablePointer(mutating: cUrl))
                    
                    // load program in ram
                    load_binary_to_ram(
                        cpu.ram,
                        opts!.pointee.data_data,
                        opts!.pointee.data_size,
                        opts!.pointee.data_vaddr
                    )
                    
                    load_binary_to_ram(
                        cpu.ram,
                        opts!.pointee.text_data,
                        opts!.pointee.text_size,
                        opts!.pointee.text_vaddr
                    )
                    
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
                    mapInstruction: $mapInstruction,
                    cpu           : cpu,
                    opts          : opts
                )
                .environmentObject(self.bodyEditorViewModel)
            }
            .sharedBackgroundVisibility(.hidden)

            // Center Section for view current file working and search file
            ToolbarItem(placement: .principal) {
                ToolbarStatusView().environmentObject(self.bodyEditorViewModel)
            }
            .sharedBackgroundVisibility(.hidden)
            
            // Search button
            ToolbarItem(placement: .principal) {
                ToolbarSearchView().environmentObject(self.bodyEditorViewModel)
                
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    // MARK: Variable show tree directory project
    private var treeSection: some View {
        return VStack {
            DirectoryTreeView(
                rootURL : URL(
                    fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath
                )
                
            ) { url in self.bodyEditorViewModel.changeOpenFile(url) }
            .environmentObject(self.bodyEditorViewModel)
            
            Spacer()
            
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: Show content editor
    private var editorArea: some View {
        let projectPath = URL(fileURLWithPath: appState.navigationState.navigationItem.selectedProjectPath)
        let isEmptyPath = self.bodyEditorViewModel.currentFileSelected == nil
        
        return ZStack {
            
            if isEmptyPath || self.bodyEditorViewModel.isSearchingFile {
                
                FileSearchView(directory: projectPath) { currentFile in
                    self.bodyEditorViewModel.changeOpenFile(currentFile.url)
                    self.bodyEditorViewModel.isSearching(false)
                    
                }
                .transition(.opacity)
                .zIndex(1)
                
            }
            
            if  !isEmptyPath {
                EditorAreaView(
                    mapInstruction: $mapInstruction,
                    projectRoot   : projectPath
                )
                .environmentObject(self.bodyEditorViewModel)
            }
        }
    }
}

#Preview {
    BodyEditorView()
}

