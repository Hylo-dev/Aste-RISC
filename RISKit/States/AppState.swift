//
//  AppState.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/09/25.
//

internal import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    var navigationState = NavigationState()
    
    @Published private var editorProjectPath: String? = nil
    
    private  var cancellables: Set<AnyCancellable> = []
    internal let objectWillChange = ObservableObjectPublisher()
    
    init(navigationState: NavigationState? = nil) {
        self.navigationState = navigationState ?? NavigationState()
        
        self.navigationState.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func setEditorProjectPath(_ path: String?) {
        guard editorProjectPath != path else { return }
        
        objectWillChange.send()
        editorProjectPath = path
    }
    
    func isSettingsFolderExist() -> Bool {
        let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let settingsFolder = path.appendingPathComponent("RISKit").appendingPathComponent("Settings")
        
        return FileManager.default.fileExists(atPath: settingsFolder.path)
    }
    
}
