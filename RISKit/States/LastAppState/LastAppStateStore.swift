//
//  LastAppStateStore.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import Foundation
internal import Combine
import SwiftUI

class LastAppStateStore: ObservableObject {
    @Published private(set) var currentState: LastAppState = LastAppState(lastPathOpened: "")

    private let fileURL: URL

    init() {
        
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = directory
            .appendingPathComponent("RISKit", isDirectory: true)
            .appendingPathComponent("StateIDE", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            
        } catch {
            print("Creation StateIDE error: ", error)
        }

        self.fileURL = folder.appendingPathComponent("last-state.json")
        load()
    }

    func changeState(path: String) {
        currentState = LastAppState(lastPathOpened: path)
        Task { await save() }
        
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            let loaded = try JSONDecoder().decode(LastAppState.self, from: data)
            self.currentState = loaded
            
        } catch {
            print("Error load state: ", error)
        }
    }

    private func save() async {
        do {
            let data = try JSONEncoder().encode(currentState)
            try data.write(to: fileURL, options: [.atomic])
            
        } catch {
            print("Error save state: ", error)
        }
    }
}
