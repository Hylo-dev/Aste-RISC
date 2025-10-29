//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI
import AppKit
import SpotlightView

struct BodyEditorView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    // Application state, contains all global view models
    @EnvironmentObject private var appState: AppState
    
    // ViewModel for manage UI body editor and RISC-V CPU Emulator
    @StateObject private var bodyEditorViewModel = BodyEditorViewModel()
	@StateObject private var cpu                 = CPU()
	@StateObject private var terminal 			 = AssemblerBridge.shared.terminal
	    
    // Options emulator
    @State private var optionsWrapper: OptionsAssemblerWrapper = OptionsAssemblerWrapper()
	
    var body: some View {
		NavigationSplitView { treeSection }
		content: { editorArea }
		detail : {
			informationArea
				.frame(minWidth: 350, idealWidth: 400, maxWidth: .infinity)
		}
			.onAppear { self.bodyEditorViewModel.changeCurrentInstruction(index: cpu.programCounter) }
			.onChange(of: cpu.programCounter, handleProgramCounterChange)
			.onChange(of: bodyEditorViewModel.currentFileSelected, handleFileSelectionChange)
			.onDisappear(perform: viewDisappearHandle)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
				
				// Section toolbar, this contains running execution button
				ToolbarItem(placement: .navigation) {
					ToolbarExecuteView(optionsWrapper: optionsWrapper)
						.environmentObject(self.bodyEditorViewModel)
						.environmentObject(self.cpu)
						.environmentObject(self.terminal)
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
                
				let viewModel = SpotlightViewModel.initFileSearch(
					directory: projectPath,
					fileExtensions: ["s", "txt"],
					configuration: .init(
						debounceInterval: 150,
						maxHeight: 400,
						showDividers: true,
						onSelect: { file in
							self.bodyEditorViewModel.changeOpenFile(file.url)
							self.bodyEditorViewModel.isSearching(false)
						},
					)
				)
				
				VStack(alignment: .center) {
					SpotlightView(viewModel: viewModel, width: 600)
						.zIndex(1)
						.padding(.top, 170)
					
					Spacer()
				}
                
            }
            
            if  !isEmptyPath,
				let editor = SettingsManager().load(file: "global_settings.json",GlobalSettings.self)?.editorUse {
								
                EditorAreaView(
					projectRoot: projectPath,
					editorUse  : editor
				)
                    .environmentObject(self.bodyEditorViewModel)
					.environmentObject(self.terminal)
            }
        }
    }
	
	private var informationArea: some View {
		// More information, for example Stack, table registers
		InformationAreaView()
			.environmentObject(self.cpu)
	}
        
    private func handleProgramCounterChange(oldValue: UInt32, newValue: UInt32) {
		guard let opts = optionsWrapper.opts else { return }
		
        bodyEditorViewModel.changeCurrentInstruction(
			index: UInt32((newValue - (opts.pointee.text_vaddr)) / 4)
        )
    }

    private func handleFileSelectionChange(oldValue: URL?, newValue: URL?) {
        guard let newValue = newValue else { return }
		
		let pathCString = strdup(newValue.path)
		self.optionsWrapper.opts = start_options(pathCString)
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

