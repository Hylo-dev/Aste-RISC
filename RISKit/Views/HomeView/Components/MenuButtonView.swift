//
//  ModeButton.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

/// The view show the button for each IDE modality
struct MenuButtonView: View {
    
    /// Rapresenting hoveing mouse on the button
    @State private var isHovering: Bool
    
    /// This is the modality rapresenting
    private let currentMode: ModalityItem
    
    init(currentMode: ModalityItem) {
        self.isHovering  = false
        self.currentMode = currentMode
    }

    var body: some View {
        
        // Button Body
        Button(action: currentMode.function) {
            
            // Row contains information button
            HStack(alignment: .center, spacing: 12) {
                iconContainer
                textContainer
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
        }
        .background(interactiveBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .onHover { hovering in isHovering = hovering }
    }

    /// Icon button
    private var iconContainer: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(.primary.opacity(0.10))
                .frame(width: 45, height: 45)

            Image(systemName: currentMode.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
        }
        
    }

    /// Column whit name and description text
    private var textContainer: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            Text(currentMode.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(currentMode.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        
    }

    /// Background button
    private var interactiveBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(backgroundFill)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }

    /// Background color, this is condition and depends if the button is hovering or not
    private var backgroundFill: Color {
        if isHovering {
            return .accentColor.opacity(0.08)
            
        } else {
            return .clear
            
        }
    }
    
    /// Border color, this is condition and depends if the button is hovering or not
    private var borderColor: Color {
        if isHovering {
            return .accentColor.opacity(0.2)
            
        } else {
            return .clear
            
        }
    }
}
