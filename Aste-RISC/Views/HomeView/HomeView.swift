import SwiftUI
import UniformTypeIdentifiers

/// The view contain the principal menu IDE, for create and open projects
struct HomeView: View {
	
	// MARK: - Enviroment var
	
	/// Use for manage principal navigation
	@EnvironmentObject
	private var navigationViewModel: NavigationViewModel
	
	// MARK: - State var
	
	/// Contains button for the modalities menu
	@State
	private var defaultsMode: [ModalityItem]?
	
	/// View model for home screen, this management the
	/// shadow color and drop trigger
	@StateObject
	private var homeViewModel: HomeViewModel = HomeViewModel()
	
	// MARK: - Statics var
	
	/// Save in cache the list used for show the mode button's
	private static var cachedModes: [ModalityItem]?
	
	// MARK: - Init Body
	
	var body: some View {
		
		// Principal row, contains the principal two columns
		HStack {
			
			// Body columns, contains principal buttons
			VStack(
				alignment: .leading,
				spacing: 25
			) {
				
				// Icon app and title
				titleEditor
				
				// Buttons menu IDE
				buttonMenuEditor
				
				Spacer()
								
				// Version sim
				Text("Aste-RISC • \(Bundle.main.appVersion)")
					.font(.footnote)
					.foregroundStyle(.tertiary)
					.padding(.leading, 12)
				
			}
			.padding()
			.frame(
				minWidth : 400,
				maxWidth : 400,
				maxHeight: .infinity,
				alignment: .leading
			)
			.glassEffect(in: .rect(cornerRadius: 26))
			
			Spacer()
			
			// Column contain the recent project opens
			// List rapresenting recent projects
			ProjectListView()
				.frame(
					minWidth : 300,
					maxWidth : 300,
					maxHeight: .infinity,
					alignment: .trailing
				)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding(15)
		.onAppear {
			
			if let cached = Self.cachedModes {
				self.defaultsMode = cached
				
			} else {
				Self.cachedModes = [
					ModalityItem(
						name: String(
							localized: "Create A New Project"
						),
						description: String(
							localized: "Create a new Assembly project"
						),
						icon: "plus.app",
						function: { [weak navigationViewModel] in
							navigationViewModel?.setSecondaryNavigation(
								secondaryNavigation: .createProject
							)
						}
					),
					
					ModalityItem(
						name: String(
							localized: "Open A Existing Project"
						),
						description: String(
							localized: "Browse your existing projects"
						),
						icon: "folder",
						function: { [weak navigationViewModel] in
							guard let vm = navigationViewModel else { return }
							showFinderPanel(navigationViewModel: vm)
						}
					)
				]
				
				self.defaultsMode = Self.cachedModes
			}
		}
		.onDrop(
			of		  : [UTType.fileURL],
			isTargeted: self.$homeViewModel.isDropping,
			perform	  : onDroppingItem
		)
		.onChange(of: self.homeViewModel.isDropping, { _, newValue in
			if newValue {
				NSHapticFeedbackManager.defaultPerformer.perform(
					.alignment,
					performanceTime: .now
				)
			}
		})
		.onPasteCommand(
			of: 	 [.fileURL],
			perform: onPastingItem
		)
	}
	
	// MARK: - Views
	
	/// Set title editor, applied a glow effect to icon editor,
	/// this effect is precalc, if is nil then calc the color.
	/// Name getting using a Bundle extension.
	private var titleEditor: some View {
		return HStack {
						
			Image(nsImage: self.homeViewModel.icon)
				.resizable()
				.frame(width: 80, height: 80)
				.if(self.homeViewModel.glowColor != nil, transform: { view in
					view.shadow(
						color : self.homeViewModel.glowColor!.opacity(0.6),
						radius: 12,
						x	  : 0,
						y	  : 0
					)
				})
			
			// Title
			VStack(
				alignment: .leading,
				spacing  : 3
			) {
				Text(Bundle.main.appName)
					.font(.largeTitle)
					.fontWeight(.bold)
					.fontDesign(.rounded)
					.foregroundStyle(.primary)
				
				Text("Open Source RISC-V IDE")
					.font(.headline)
					.fontWeight(.medium)
					.foregroundStyle(.secondary)
			}
		}
	}
	
	/// Create a list of buttons for create or open
	/// the projects.
	private var buttonMenuEditor: some View {
		return VStack(spacing: 15) {
			
			if let modesList = self.defaultsMode {
				ForEach(modesList, id: \.id) { mode in
					MenuButtonView(currentMode: mode)
						.frame(maxWidth: 400)
				}
			}
		}
	}
	
	// MARK: - Handlers
	
	/// When user drag and dropping the item in capture
	/// window, the app call this fuction and
	/// get the URL system if is not nil.
	private func onDroppingItem(_ providers: [NSItemProvider]) -> Bool {
		
		// Control first item exist
		guard let provider = providers.first else { return false }
		
		// Load URL object, function return a progress value
		// for use in circular progress, but I not use self because
		// open a URL is very fast on modern Apple system.
		let _ = provider.loadObject(ofClass: URL.self) { url, error in
			guard let url = url else { return }
			
			Task { @MainActor in
				
				// ----- Set IDE in open project modality -----
				
				self.navigationViewModel.setProjectInformation(
					url: url.path,
					name: url.lastPathComponent
				)
				
				self.navigationViewModel.setSecondaryNavigation(
					secondaryNavigation: .openDirectlyProject
				)
				
				// Active vibration trackpad
				NSHapticFeedbackManager.defaultPerformer.perform(
					.generic,
					performanceTime: .now
				)
				
				NSApp.activate(ignoringOtherApps: true)
			}
		}
				
		return true
	}
	
	/// When you copy a folder and paste self in IDE home
	/// open directly project.
	private func onPastingItem(_ providers: [NSItemProvider]) {
		
		// Control first item exist
		guard let provider = providers.first else { return }
		
		// Load URL object, function return a progress value
		// for use in circular progress, but I not use self because
		// open a URL is very fast on modern Apple system.
		let _ = provider.loadObject(ofClass: URL.self) { url, error in
			guard let url = url else { return }
						
			Task { @MainActor in
				
				// ----- Set IDE in open project modality -----
				
				self.navigationViewModel.setProjectInformation(
					url: url.path,
					name: url.lastPathComponent
				)
				
				self.navigationViewModel.setSecondaryNavigation(
					secondaryNavigation: .openProject
				)
				
				// Active vibration trackpad
				NSHapticFeedbackManager.defaultPerformer.perform(
					.generic,
					performanceTime: .now
				)
				
				NSApp.activate(ignoringOtherApps: true)
			}
		}
	}
}
