//
//  EditorView.swift
//  Aster-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI
import SpotlightView

/// The main view coordinating the RISC-V editing and simulation environment.
///
/// This view uses a `NavigationSplitView` to organize the file navigator
/// (`NavigatiorAreaView`), the central code editor (`editorArea`),
/// and the simulation details pane (`InformationAreaView`).
///
/// It manages the lifecycle of key models like the `CPU` and `BodyEditorViewModel`,
/// handles file selection, and coordinates the UI state (e.g., search overlays).
struct BodyEditorView: View {
	 
	@Environment(\.openWindow)
	private var openWindow
	 
	/// Controls the focus state overlay.
	@FocusState
	private var spotlightFocused: ComponentFocusState?
	 
	/// The primary ViewModel managing UI state, editor content, and compilation logic.
	@StateObject
	private var bodyEditorViewModel: BodyEditorViewModel = BodyEditorViewModel()
	
	/// The RISC-V CPU emulator model, tracking registers and program state.
	@StateObject
	private var cpu: CPU
	
	/// The RISC-V RAM UI model, tracking change instructions and update stack state
	@StateObject
	private var stackViewModel: StackViewModel
	
	/// An observed object reflecting the shared terminal output.
	@ObservedObject
	private var terminal: TerminalOutputModel = AssemblerBridge.shared.terminal
	
	/// The ViewModel for the `MultiSectionSpotlightView` (file search overlay).
	///
	/// This property is initialized in `.onAppear` to avoid performance issues
	/// during view rendering.
	@State
	private var spotlightViewModel: MultiSectionSpotlightViewModel<SpotlightFileItem>?
	
	/// The user's preferred editor, loaded from global settings.
	///
	/// This property is loaded in `.onAppear` to prevent re-reading the settings
	/// file on every view render.
	@State
	private var editorSetting: Editors?
	
	/// The absolute file system path to the root of the user's project.
	let selectedProjectPath: String
	
	/// The display name of the user's project.
	let selectedProjectName: String
	
	init(
		selectedProjectPath: String,
		selectedProjectName: String
	) {
		self.selectedProjectPath = selectedProjectPath
		self.selectedProjectName = selectedProjectName
		
		// Temp cpu object instance
		// Use it for init stack view model and cpu state object
		let cpuInstance 	 = CPU()
		self._cpu 		     = StateObject(wrappedValue: cpuInstance)
		self._stackViewModel = StateObject(wrappedValue: StackViewModel(cpu: cpuInstance))
		
		self.spotlightFocused = .editor
	}
		
	var body: some View {
		ZStack {
		
			NavigationSplitView {
				NavigatiorAreaView(
					fileSelected: self.$bodyEditorViewModel.fileSelected,
					projectPath : self.selectedProjectPath,
					isFocused   : self.spotlightFocused == .navigation
				)
				.focusable()
				.focused(self.$spotlightFocused, equals: .navigation)
				.focusEffectDisabled(true)
				
			} content: {
				editorArea
				
			} detail : {
				// More information, for example Stack, table registers
				InformationAreaView(fileSelected: self.$bodyEditorViewModel.fileSelected)
					.environmentObject(self.cpu)
					.environmentObject(self.stackViewModel)
					.environmentObject(self.bodyEditorViewModel.optionsWrapper)
					.frame(
						minWidth  : 350,
						idealWidth: 400,
						maxWidth  : .infinity
					)
			}
			.onAppear(perform: handleOnAppear)
			.onChange(of: self.cpu.programCounter) { _, newValue in
				self.stackViewModel.handleProgramCounterChange(
					newValue	  : newValue,
					optionsWrapper: self.bodyEditorViewModel.optionsWrapper
				)
			}
			.onChange(
				of: self.bodyEditorViewModel.fileSelected,
				self.bodyEditorViewModel.handleFileSelectionChange
			)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.toolbar {
					
				// Section toolbar, this contains running execution button
				ToolbarItem(placement: .navigation) { toolbarExecute }
					.sharedBackgroundVisibility(.hidden)

				// Center Section for view current file working and search file
				ToolbarItem(placement: .principal) { toolbarStatus }
					.sharedBackgroundVisibility(.hidden)
					
				// Search button
				ToolbarItem(placement: .principal) { toolbarSearch }
					.sharedBackgroundVisibility(.hidden)
			}
			
			// Dimming overlay when searching
			if self.bodyEditorViewModel.isSearchingFile {
				Rectangle()
					.fill(.black.opacity(0.18))
					.ignoresSafeArea()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.onTapGesture {
						withAnimation(.spring()) { self.bodyEditorViewModel.isSearchingFile = false }
					}
					.zIndex(0)
			}
		}
	}
	
	// MARK: - Views
	
	/// The navigation toolbar item containing execution controls (run, step, etc.).
	private var toolbarExecute: some View {
		ToolbarExecuteView(
			viewModel	  : self.bodyEditorViewModel,
			mapInstruction: self.$stackViewModel.mapInstruction
		)
		.environmentObject(self.cpu)
	}
	 
	/// The principal toolbar item displaying the current file path.
	private var toolbarStatus: some View {
		ToolbarStatusView(
			fileSelected     : self.$bodyEditorViewModel.fileSelected,
			selectProjectName: self.selectedProjectName
		)
		.environmentObject(self.bodyEditorViewModel)
	}
	
	/// The principal toolbar item containing the file search button.
	private var toolbarSearch: some View {
		ToolbarSearchView(fileSelected: self.$bodyEditorViewModel.fileSelected)
			.environmentObject(self.bodyEditorViewModel)
	}
	
	/// The main content area, which displays either the file editor or
	/// the Spotlight search overlay.
	private var editorArea: some View {
		let isEmptyPath = self.bodyEditorViewModel.fileSelected == nil
			  
		return ZStack {
			if  !isEmptyPath, let editor = self.editorSetting {
								
				EditorAreaView(
					projectRoot : URL(fileURLWithPath: self.selectedProjectPath),
					editorUse   : editor,
					fileSelected: self.$bodyEditorViewModel.fileSelected
				)
				.environmentObject(self.bodyEditorViewModel)
				.environmentObject(self.terminal)
				.zIndex(0)
				
			}
			
			// Show Spotlight search if no file is open or if search is active
			if isEmptyPath || self.bodyEditorViewModel.isSearchingFile {
				VStack(alignment: .center) {
					
					// Note: Assumes spotlightViewModel is non-nil
					// when this view is shown.
					MultiSectionSpotlightView(viewModel: self.spotlightViewModel!, width: 600)
						.focused($spotlightFocused, equals: .spotlight)
						.onAppear { self.spotlightFocused = .spotlight }
						.zIndex(2)
						.padding(.top, 170)
					
					Spacer()
				}
			}
		}
	}
	
	// MARK: - Handles
	
	/// Performs initial setup when the view first appears.
	///
	/// This function:
	/// 1. Loads the user's editor setting.
	/// 2. Initializes the C-options based on the last selected file.
	/// 3. Initializes the Spotlight file search ViewModel.
	/// 4. Validates the last selected file path.
	/// 5. Syncs the instruction map with the CPU's program counter.
	private func handleOnAppear() {
		if self.editorSetting == nil {
			self.editorSetting = SettingsManager().load(
				file: "global_settings.json",
				GlobalSettings.self
			)?.editorUse
		}
		
		// Load C-options for the currently selected file
		self.bodyEditorViewModel.handleFileSelectionChange(
			oldValue: nil,
			newValue: self.bodyEditorViewModel.fileSelected
		)
		
		if self.spotlightViewModel == nil {
			self.handleInitializeSpotlightViewModel()
		}
		
		// Validate if the last open file is part of the current project
		if let file = self.bodyEditorViewModel.fileSelected,
			!file.absoluteString.contains(self.selectedProjectPath
		) {
			self.bodyEditorViewModel.fileSelected = nil
		}
		
		self.stackViewModel.mapInstruction.indexInstruction = self.cpu.programCounter
	}
	
	/// Creates and configures the `MultiSectionSpotlightViewModel`.
	///
	/// This sets up the data source (file system) and defines the action
	/// to take when a file is selected from the search results.
	private func handleInitializeSpotlightViewModel() {
		let projectPath = URL(fileURLWithPath: selectedProjectPath)
		
		self.spotlightViewModel = MultiSectionSpotlightViewModel<SpotlightFileItem>(
			dataSource: FileSystemDataSource(
				directory: projectPath,
				fileExtensions: ["s", "txt"]
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
					// When a file is selected from Spotlight,
					// update the app state and close the search.
					self.bodyEditorViewModel.fileSelected    = file.url
					self.bodyEditorViewModel.isSearchingFile = false
				}
			)
		)
	}
}
