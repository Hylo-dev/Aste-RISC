//
//  ProjectCreator.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation

actor ProjectCreator {
    static let shared = ProjectCreator()

    func createProject(
        at baseDirectory: URL,
        name projectName: String
    ) async throws -> URL {

        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw ProjectCreationError.invalidProjectName }

        let projectDir = baseDirectory.appendingPathComponent(trimmedName, isDirectory: true)
        let srcDir = projectDir.appendingPathComponent("src", isDirectory: true)

        if FileManager.default.fileExists(atPath: projectDir.path) {
            throw ProjectCreationError.projectAlreadyExists(projectDir)
        }

        try FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)

        let mainFileName = "main.s"

        let mainTemplate = try loadTemplateText(resourceName: mainFileName, extension: "template")
        
        let mainURL = srcDir.appendingPathComponent(mainFileName)
        try writeText(mainTemplate, to: mainURL)

        return projectDir
    }

    // MARK: - Helpers

    private func loadTemplateText(resourceName: String, extension ext: String) throws -> String {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: ext) else {
            throw ProjectCreationError.templateNotFound("\(resourceName).\(ext)")
        }
		
        do {
            let data = try Data(contentsOf: url)
            guard let text = String(data: data, encoding: .utf8) else {
                throw ProjectCreationError.bundleReadFailed(url)
            }
			
            return text
			
        } catch {
            throw ProjectCreationError.bundleReadFailed(url)
        }
    }

    private func writeText(_ text: String, to url: URL) throws {
        do {
            try text.data(using: .utf8)?.write(to: url, options: [.atomic])
			
        } catch {
            throw ProjectCreationError.writeFailed(url)
        }
    }
}
