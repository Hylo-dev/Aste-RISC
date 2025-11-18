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
        at   baseDirectory: URL,
        name projectName  : String
		
    ) async -> (
		projectUrl: URL?,
		error: 		String?
	) {

        let trimmedName = projectName.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
				
		guard !trimmedName.isEmpty else {
			return (
				nil,
				ProjectCreationError.invalidProjectName.localizedDescription
			)
		}

		// Get the main project path
        let projectDir = baseDirectory.appendingPathComponent(
			trimmedName,
			isDirectory: true
		)
		
		// Append to project dir the source folder
        let srcDir = projectDir.appendingPathComponent(
			"src",
			isDirectory: true
		)

        if FileManager.default.fileExists(atPath: projectDir.path) {
            return (
				nil,
				ProjectCreationError.projectAlreadyExists(
					projectDir
				).localizedDescription
			)
        }

		do {
			try FileManager.default.createDirectory(
				at: srcDir,
				withIntermediateDirectories: true
			)

			let mainFileName = "main.s"

			let mainTemplate = try loadTemplateText(
				resource : mainFileName,
				extension: "template"
			)
			
			let mainURL = srcDir.appendingPathComponent(mainFileName)
			try write(mainTemplate, to: mainURL)
			
		} catch { return (nil, error.localizedDescription) }

        return (projectDir, nil)
    }

    // MARK: - Handlers

	/// Load template for assembly main, this permitted create a not empty file
    private func loadTemplateText(
		resource  resourceName: String,
		extension ext	      : String
		
	) throws -> String {
        guard let url = Bundle.main.url(
			forResource  : resourceName,
			withExtension: ext
			
		) else {
            throw ProjectCreationError.templateNotFound(
				"\(resourceName).\(ext)"
			)
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

	/// Write text to file
    private func write(
		_ text: String,
		to url: URL
	) throws {
        do {
            try text.data(using: .utf8)?.write(to: url, options: [.atomic])
			
        } catch {
            throw ProjectCreationError.writeFailed(url)
        }
    }
}
