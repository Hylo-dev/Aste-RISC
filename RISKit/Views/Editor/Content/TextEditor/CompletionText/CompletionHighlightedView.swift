//
//  CompletionHighlightedView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/09/25.
//

import SwiftUI

struct CompletionHighlightedView: View {
    let text: String
    @State private var attributed: AttributedString? = nil
    @ObservedObject private var highlighter = Highlighter.shared

    var body: some View {
        Group {
            if let attributed = attributed {
                Text(attributed)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Lightweight placeholder while computing
                Text(text)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0.8)
            }
        }
        .onChange(of: text) { _, new in
            
            highlighter.highlight(new, language: "c") { attr in
                if new == text {
                    self.attributed = attr
                }
            }
            
        }
        .onAppear {
            highlighter.highlight(text, language: "c") { attr in
                if text == self.text { self.attributed = attr }
            }
        }
    }
}
