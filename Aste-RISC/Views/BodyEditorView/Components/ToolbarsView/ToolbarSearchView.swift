//
//  ToolbarSearchView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/10/25.
//

import SwiftUI

struct ToolbarSearchView: View {
	
	@Binding
	private var isFileSearching: Bool
	
	init(isFileSearching: Binding<Bool>) {
		self._isFileSearching = isFileSearching
	}
    
    var body: some View {
        
        Button {
            withAnimation(.spring()) {
				self.isFileSearching.toggle()
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
