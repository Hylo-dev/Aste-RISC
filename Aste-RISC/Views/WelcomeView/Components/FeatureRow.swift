//
//  RequirementRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

/// Row to show support features IDE
struct FeatureRow: View {
    
    /// Current feature to show
    let feature: FeatureItem
    
    var body: some View {
        
        // Row body
        HStack(alignment: .center) {
            
            // Show small box with single icon
            ZStack {
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(feature.colorBgIcon.opacity(0.18))
                    .frame(width: 32, height: 32)
                
                Image(systemName: feature.icon)
                    .frame(width: 24, height: 24)
                
            }
                        
            // Column body to show information feature
            VStack(alignment: .leading) {
                
                Text(feature.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            }
        }
    }
}
