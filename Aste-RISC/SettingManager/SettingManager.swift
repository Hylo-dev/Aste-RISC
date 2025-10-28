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
        
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        }
    }

    func load<T: SettingsInterface>(
        folder folderName: String = "Settings",
        file fileName: String,
        _ type: T.Type
        
    ) -> T? {
        let fileURL = baseURL
            .appendingPathComponent(folderName) // -> "Settings"
            .appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let settings = try JSONDecoder().decode(T.self, from: data)
            
            return settings
            
        } catch {
            
            print("Error to load setting:\n", error)
            return nil
        }
    }

    func save<T: SettingsInterface>(
        folder folderName: String = "Settings",
        _ settings: T
        
    ) {
        let folderURL = baseURL
            .appendingPathComponent(folderName) // -> "Settings"
        
        try? FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true
        )
        
        let fileURL = folderURL
            .appendingPathComponent(settings.fileName)
        
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: fileURL)
        }
    }
}
