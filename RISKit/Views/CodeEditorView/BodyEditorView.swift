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
    
    // Options emulator
    @State private var opts: UnsafeMutablePointer<options_t>? = nil

    var body: some View {
        NavigationSplitView() { treeSection } content: { editorArea } detail: {
            // More information, for example Stack, table registers
            VStack { Text("Test") }
            
        }
        .onAppear { self.bodyEditorViewModel.changeCurrentInstruction(index: cpu.programCounter) }
        .onChange(of: cpu.programCounter, handleProgramCounterChange)
        .onChange(of: bodyEditorViewModel.currentFileSelected, handleFileSelectionChange)
        .onDisappear(perform: viewDisappearHandle)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            
            // Section toolbar, this contains running execution button
            ToolbarItem(placement: .navigation) {
                ToolbarExecuteView(
                    cpu : cpu,
                    opts: opts
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
                EditorAreaView(projectRoot: projectPath)
                    .environmentObject(self.bodyEditorViewModel)
            }
        }
    }
        
    private func handleProgramCounterChange(oldValue: UInt32, newValue: UInt32) {
        guard let opts = opts else { return }
        bodyEditorViewModel.changeCurrentInstruction(
            index: UInt32((newValue - opts.pointee.text_vaddr) / 4)
        )
    }

    private func handleFileSelectionChange(oldValue: URL?, newValue: URL?) {
        guard let newValue = newValue else { return }

        newValue.path.withCString { cUrl in
            opts = start_options(UnsafeMutablePointer(mutating: cUrl))
            load_binary_to_ram(cpu.ram, opts!.pointee.data_data, opts!.pointee.data_size, opts!.pointee.data_vaddr)
            load_binary_to_ram(cpu.ram, opts!.pointee.text_data, opts!.pointee.text_size, opts!.pointee.text_vaddr)
        }
    }
    
    private func viewDisappearHandle() {
        withTransaction(Transaction(animation: nil)) {
            appState.setEditorProjectPath(nil)
            appState.navigationState.saveCurrentProjectState(path: "")
        }
        
        Task { openWindow(id: "home") }
    }

}

#Preview {
    BodyEditorView()
}

