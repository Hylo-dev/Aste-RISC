//
//  Bundle+VersionApp.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/11/25.
//

import Foundation

extension Bundle {
	
	var appVersion: String {
		let version = object(
			forInfoDictionaryKey: "CFBundleShortVersionString"
		) as? String ?? "1.0"
		
		let build = object(
			forInfoDictionaryKey: "CFBundleVersion"
		) as? String ?? "1"
		
		return "Version \(version) (\(build))"
	}
}
