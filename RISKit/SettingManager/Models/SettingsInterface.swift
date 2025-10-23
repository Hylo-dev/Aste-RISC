//
//  SettingSection.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation
internal import Combine

protocol SettingsInterface: Codable, Identifiable {
    var fileName: String { get set }
    init()
}
