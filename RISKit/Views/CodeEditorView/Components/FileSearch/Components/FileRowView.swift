//
//  FileRowView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import SwiftUI

struct FileRowView: View {
    let item             : FileItem
    let currentIndex     : Int
    let fileSelectedIndex: Int
    let onTap            : () -> Void
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: IconCache.shared.icon(for: item.url))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.url.deletingLastPathComponent().path)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(10)
        .background(self.currentIndex == self.fileSelectedIndex ? Color.accentColor.opacity(0.15) : Color.clear)
        .cornerRadius(8)
        .id(self.currentIndex)
        .onTapGesture { onTap() }
    }
}
