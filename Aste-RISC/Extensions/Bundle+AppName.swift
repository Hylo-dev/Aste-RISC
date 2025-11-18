//
//  Bundle+AppName.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/11/25.
//

import Foundation

extension Bundle {
	var appName: String {
		let displayName = object(
			forInfoDictionaryKey: "CFBundleDisplayName"
		) as? String
		
		let bundleName = object(
			forInfoDictionaryKey: "CFBundleName"
		) as? String
			
		return displayName ?? bundleName ?? "appSwift"
	}
}
