//
//  ToolbarSearchView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarSearchView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    
    var body: some View {
        
        Button {
            withAnimation(.spring()) {
                if self.bodyEditorViewModel.currentFileSelected != nil {
                    self.bodyEditorViewModel.toggleSearching()
                }
            }
            
        } label: {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .frame(width: 35, height: 35)
                .contentShape(Circle())
            
        }
        .buttonStyle(.plain)
        .glassEffect(in: .circle)
        .clipShape(Circle())
        .padding(.leading, 20)
    }
}
