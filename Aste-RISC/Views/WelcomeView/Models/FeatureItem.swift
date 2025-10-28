//
//  RequirementItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

/// Contain information for the feature
struct FeatureItem: Hashable, Identifiable {
    
    /// ID feature
    let id: Int8
    
    /// Title feature
    let title: String
    
    /// Description Feature
    let description: String
    
    /// Icon Feature
    let icon: String
    
    /// Color background icon feature
    let colorBgIcon: Color
}
