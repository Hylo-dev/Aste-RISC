import SwiftUI

/// The view contain the principal menu IDE, for create and open projects
struct HomeView: View {
    
    /// Contains the prinripal state's app
    @EnvironmentObject private var appState: AppState
    
    /// Contain the glow color in cache
    @State static private var cachedColor: NSColor? = nil
    
    /// Contains button for the modalities menu
    @State private var defaultsMode: [ModeItem] = []
    
    /// Contain the task to calculate the glow color
    @State private var colorTask: Task<Void, Never>? = nil
    
    /// Glow color, this use the app icon color
    @State private var glowColor: Color = .white
            
    /// App version string
    private static var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    // Get the app icon
    private static let icon = NSApplication.shared.applicationIconImage!

    var body: some View {
        
        // Principal row, contains the principal two columns
        HStack {

            // Body columns, contains principal buttons
            VStack(
                alignment: .leading,
                spacing: 25
            ) {
                
                // Icon app and title
                HStack {
                    
                    Image(nsImage: Self.icon)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .shadow(color: glowColor.opacity(0.6), radius: 12, x: 0, y: 0)
                        .onAppear {
                            if let cached = Self.cachedColor {
                                self.glowColor = Color(cached)
                                
                            } else {
                                colorTask = Task(priority: .userInitiated) { @MainActor in
                                    let nsColor = await computeAverageColor(of: Self.icon)
                                    self.glowColor = Color(nsColor ?? .white)
                                    Self.cachedColor = nsColor
                                }
                            }
                        }
                        .onDisappear {
                            colorTask?.cancel()
                            colorTask = nil
                        }
                    
                    // Tittle
                    VStack(alignment: .leading) {
                        Text("RISKit")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        
                        Text("Open Source RISC-V Simulator")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Buttons menu IDE
                VStack(spacing: 15) {
                    
                    ForEach(defaultsMode) { mode in
                        ModeButton(currentMode: mode)
                            .frame(maxWidth: 400)
                    }
                    
                }
                
                Spacer()
                
                // Version sim
                Text("RISKit • \(Self.appVersionString)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 12)
                
            }
            .padding()
            .frame(minWidth: 400, maxWidth: 400, maxHeight: .infinity, alignment: .leading)
            .glassEffect(in: .rect(cornerRadius: 26))
            
            Spacer()

            // Column contain the recent project opens
            ProjectRecentView(navigationState: appState.navigationState, recentProjectsStore: appState.recentProjectsStore)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(15)
        .onAppear {
            
            // When column show, this get the values
            if defaultsMode.isEmpty {
                defaultsMode = [
                    ModeItem(
                        name: "Create A New Project",
                        description: "Create a new Assembly project",
                        icon: "plus.app",
                        function: { self.appState.navigationState.setSecondaryNavigation(currentSecondaryNavigation: .CREATE_PROJECT) }
                    ),
                    
                    ModeItem(
                        name: "Open A Existing Project",
                        description: "Browse your existing projects",
                        icon: "folder",
                        function: { showFinderPanel(navigationState: self.appState.navigationState) }
                    )
                ]
            }
        }
    }
}
