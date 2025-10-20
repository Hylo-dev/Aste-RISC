//
//  SettingStorage.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation

class SettingsManager {
     private let baseURL: URL

    init() {
        let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseURL  = path
            .appendingPathComponent("RISKit")
            .appendingPathComponent("Settings")
        
        try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    func load<T: SettingsInterfarce>(_ type: T.Type) -> T {
        let fileURL = baseURL.appendingPathComponent(T.fileName)
        if let data = try? Data(contentsOf: fileURL),
           let settings = try? JSONDecoder().decode(T.self, from: data) {
            return settings
            
        }
        
        return T()
    }

    func save<T: SettingsInterfarce>(_ settings: T) {
        let fileURL = baseURL.appendingPathComponent(T.fileName)
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: fileURL)
        }
    }
}
