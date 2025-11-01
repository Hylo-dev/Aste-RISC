//
//  ModalityBoxView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ModalityBoxView: View {
    @State private var isHovering = false

    let currentModality: CreationModalityItem
    let isSelected     : Bool             // read-only: il genitore decide
    let onSelect       : () -> Void

    init(
        currentModality: CreationModalityItem,
        isSelected: Bool,
        onSelect: @escaping () -> Void
        
    ) {
        self.currentModality = currentModality
        self.isSelected      = isSelected
        self.onSelect        = onSelect
        
    }

    var body: some View {
        Button(action: onSelect) {
            
            HStack(alignment: .center, spacing: 12) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(currentModality.title)
                        .font(.headline)

                    Text(currentModality.description)
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.white.opacity(0.9) : .secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                Spacer()
				
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(background)
            .overlay(overlay)
			
        }
        .buttonStyle(.plain)
        .onHover { hovering in withAnimation(.easeInOut(duration: 0.12)) { isHovering = hovering } }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected
                  ? Color.accentColor
                  : (isHovering ? .accentColor.opacity(0.09) : Color.clear))
    }
    
    private var overlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(isSelected
                          ? Color.accentColor
                          : (isHovering ? .accentColor.opacity(0.18) : Color.clear),
                          lineWidth: isSelected ? 2 : 1)
    }
}
