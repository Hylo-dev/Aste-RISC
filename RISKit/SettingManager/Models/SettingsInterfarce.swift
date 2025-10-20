//
//  SettingSection.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import Foundation
internal import Combine

protocol SettingsInterfarce: Codable, Identifiable {
    static var fileName: String { get }
    init()
}
