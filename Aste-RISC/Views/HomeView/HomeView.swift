import SwiftUI

/// The view contain the principal menu IDE, for create and open projects
struct HomeView: View {
	
	/// Get the app icon and save ther in struct instance,
	/// because not get this `n` times
	private static let icon = NSApplication.shared.applicationIconImage!
    
    /// Use for manage principal navigation
	@EnvironmentObject
	private var navigationViewModel: NavigationViewModel
	
	/// Contains button for the modalities menu
	@State
	private var defaultsMode: [ModalityItem] = []
    
    /// Contain the glow color in cache
    @State
	static private var cachedColor: NSColor?
    
    /// Contain the task to calculate the glow color
    @State
	private var colorTask: Task<Void, Never>?
    
    /// Glow color, this use the app icon color
    @State
	private var glowColor: Color?

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
			if defaultsMode.isEmpty {
				defaultsMode = [
					ModalityItem(
						name: "Create A New Project",
						description: "Create a new Assembly project",
						icon: "plus.app",
						function: { [weak navigationViewModel] in
							navigationViewModel?.setSecondaryNavigation(
								secondaryNavigation: .createProject
							)
						}
					),
					
					ModalityItem(
						name: "Open A Existing Project",
						description: "Browse your existing projects",
						icon: "folder",
						function: { [weak navigationViewModel] in
							guard let vm = navigationViewModel else { return }
							showFinderPanel(navigationViewModel: vm)
						}
					)
				]
			}
		}
    }
	
	// MARK: - Views
    
    private var titleEditor: some View {
        return HStack {
            
            Image(nsImage: Self.icon)
                .resizable()
                .frame(width: 80, height: 80)
				.if(self.glowColor != nil, transform: { view in
					view.shadow(
						color  : glowColor!.opacity(0.6),
						 radius: 12,
						 x	   : 0,
						 y	   : 0
					 )
				})
                .onAppear {
					
					// Get color shadow for icon,
					// if is in cache then load, else calc shadow
                    if let cached = Self.cachedColor {
                        self.glowColor = Color(cached)
                        
                    } else {
						colorTask = Task(
							priority: .userInitiated
						) { @MainActor in
							
                            let nsColor = await computeAverageColor(
								of: Self.icon
							)
							
                            self.glowColor = Color(nsColor ?? .white)
                            Self.cachedColor = nsColor
                        }
                    }
                }
                .onDisappear {
					// Cancel calc shadow
                    colorTask?.cancel()
                    colorTask = nil
                }
            
            // Tittle
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
    
    private var buttonMenuEditor: some View {
        return VStack(spacing: 15) {
            
			ForEach(defaultsMode, id: \.id) { mode in
                MenuButtonView(currentMode: mode)
					.frame(maxWidth: 400)
            }
        }
    }
}
