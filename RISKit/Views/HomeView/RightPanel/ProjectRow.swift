//
//  ProjectRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ProjectRow: View {
    let project : RecentProject
    var onSelect: () -> Void
    var onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        
        Button(action: onSelect) {
            HStack(spacing: 10) {
                
                Image(nsImage: IconCache.shared.icon(for: nil))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(project.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .opacity(isHovering ? 1 : 0)
            }
        }
        .padding()
        .buttonStyle(.plain)
        .background(interactiveBackground)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        
    }
    
    private var interactiveBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(backgroundFill)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }

    private var backgroundFill: Color {
        if isHovering {
            return .accentColor.opacity(0.10)
            
        } else {
            return .secondary.opacity(0.12)
            
        }
    }

    private var borderColor: Color {
        if isHovering {
            return .accentColor.opacity(0.2)
            
        } else {
            return .clear
            
        }
    }
}

