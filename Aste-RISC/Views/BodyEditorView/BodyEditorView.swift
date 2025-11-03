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
    
	@FocusState private var spotlightFocused: Bool
	@AppStorage("lastFileOpen") private var fileSelected: URL?
    
    // ViewModel for manage UI body editor and RISC-V CPU Emulator
    @StateObject private var bodyEditorViewModel = BodyEditorViewModel()
	@StateObject private var cpu                 = CPU()
	@StateObject private var terminal 			 = AssemblerBridge.shared.terminal
	    
    // Options emulator
    @State private var optionsWrapper: OptionsAssemblerWrapper = OptionsAssemblerWrapper()
	
	let selectedProjectPath: String
	let selectedProjectName: String
		
    var body: some View {
		ZStack {
		
			NavigationSplitView { treeSection }
			content: { editorArea }
			detail : {
				informationArea
					.frame(minWidth: 350, idealWidth: 400, maxWidth: .infinity)
			}
			.onAppear {
				
				if let file = self.fileSelected, !file.absoluteString.contains(self.selectedProjectPath) {
					self.fileSelected = nil
				}
				
				self.bodyEditorViewModel.changeCurrentInstruction(index: self.cpu.programCounter)
			}
			.onChange(of: cpu.programCounter, handleProgramCounterChange)
			.onChange(of: self.fileSelected, handleFileSelectionChange)
			//.onChange(of: bodyEditorViewModel.currentFileSelected, handleFileSelectionChange)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
					
				// Section toolbar, this contains running execution button
				ToolbarItem(placement: .navigation) {
					ToolbarExecuteView(
						optionsWrapper     : self.optionsWrapper,
						isOutputVisible    : self.$bodyEditorViewModel.isOutputVisible,
						editorState        : self.$bodyEditorViewModel.editorState,
						mapInstruction 	   : self.$bodyEditorViewModel.mapInstruction,
						currentFileSelected: self.fileSelected
						//currentFileSelected: self.bodyEditorViewModel.currentFileSelected
					)
						.environmentObject(self.bodyEditorViewModel)
						.environmentObject(self.cpu)
						.environmentObject(self.terminal)
				}
				.sharedBackgroundVisibility(.hidden)

				// Center Section for view current file working and search file
				ToolbarItem(placement: .principal) {
					ToolbarStatusView(
						fileSelected	 : self.$fileSelected,
						selectProjectName: self.selectedProjectName
					)
					.environmentObject(self.bodyEditorViewModel)
				}
				.sharedBackgroundVisibility(.hidden)
					
				// Search button
				ToolbarItem(placement: .principal) {
					ToolbarSearchView(fileSelected: self.$fileSelected)
						.environmentObject(self.bodyEditorViewModel)
						
				}
				.sharedBackgroundVisibility(.hidden)
			}
			
			if self.bodyEditorViewModel.isSearchingFile {
				Rectangle()
					.fill(.black.opacity(0.18))
					.ignoresSafeArea()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.onTapGesture {
						withAnimation(.spring()) { self.bodyEditorViewModel.isSearchingFile = false }
					}
					.zIndex(1)
			}
		}
    }
    
    // MARK: Variable show tree directory project
    private var treeSection: some View {
        return VStack {
            DirectoryTreeView(
                rootURL : URL(
                    fileURLWithPath: selectedProjectPath
				),
				fileOpen: self.$fileSelected //self.$bodyEditorViewModel.currentFileSelected
                
			) { url in self.fileSelected = url } // self.bodyEditorViewModel.changeOpenFile(url)
            .environmentObject(self.bodyEditorViewModel)
            
            Spacer()
            
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: Show content editor
    private var editorArea: some View {
        let projectPath = URL(fileURLWithPath: selectedProjectPath)
		let isEmptyPath = self.fileSelected == nil // self.bodyEditorViewModel.currentFileSelected == nil
		
		let viewModel = MultiSectionSpotlightViewModel<SpotlightFileItem>(
			dataSource: FileSystemDataSource(
				directory: projectPath,
				fileExtensions: ["s", "txt"],
			),
			sections: [
				SpotlightSection(
					id: "test",
					title: "Create file",
					icon: "document",
					view: { EmptyView() },
					onSelect: { file in print(file) }
				)
			],
			configuration: .init(
				debounceInterval: 150,
				maxHeight: 400,
				showDividers: true,
				onSelect: { file in
					self.fileSelected = file.url

					//self.bodyEditorViewModel.changeOpenFile(file.url)
					self.bodyEditorViewModel.isSearching(false)
				},
			)
		)
        
        return ZStack {
            if  !isEmptyPath,
				let editor = SettingsManager().load(file: "global_settings.json",GlobalSettings.self)?.editorUse {
								
                EditorAreaView(
					projectRoot : projectPath,
					editorUse   : editor,
					fileSelected: self.$fileSelected
				)
				.environmentObject(self.bodyEditorViewModel)
				.environmentObject(self.terminal)
				.zIndex(0)
				
            }
			
			if isEmptyPath || self.bodyEditorViewModel.isSearchingFile {
				VStack(alignment: .center) {
					MultiSectionSpotlightView(viewModel: viewModel, width: 600)
						.focused($spotlightFocused)
						.onAppear {
							self.spotlightFocused = true
						}
						.zIndex(2)
						.padding(.top, 170)
					
					Spacer()
				}
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
		if self.optionsWrapper.opts != nil {
			free_options(self.optionsWrapper.opts)
			self.optionsWrapper.opts = nil
		}
		
        guard let newValue = newValue else { return }
		
		newValue.path.withCString { pathAsCString in
			self.optionsWrapper.opts = start_options(UnsafeMutablePointer(mutating: pathAsCString))
		}
    }
}

#Preview {
	BodyEditorView(
		selectedProjectPath: "",
		selectedProjectName: ""
	)
}

