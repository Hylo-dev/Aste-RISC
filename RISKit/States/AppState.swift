//
//  AppState.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

internal import Combine

@MainActor
final class AppState: ObservableObject {
    var navigationState     = NavigationState()
    var recentProjectsStore = RecentProjectsStore()
    
    @Published private var editorProjectPath: String? = nil
    
    private  var cancellables: Set<AnyCancellable> = []
    internal let objectWillChange = ObservableObjectPublisher()
    
    init(
        navigationState: NavigationState?         = nil,
        recentProjectsStore: RecentProjectsStore? = nil
    ) {
        self.navigationState     = navigationState     ?? NavigationState()
        self.recentProjectsStore = recentProjectsStore ?? RecentProjectsStore()
        
        self.navigationState.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        self.recentProjectsStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func setEditorProjectPath(_ path: String?) {
        guard editorProjectPath != path else { return }
        
        objectWillChange.send()
        editorProjectPath = path
    }
    
}
