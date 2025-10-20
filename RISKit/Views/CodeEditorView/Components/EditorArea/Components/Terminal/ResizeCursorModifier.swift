//
//  ResizeCursorModifier.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/08/25.
//

import SwiftUI

struct ResizeCursorModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.onHover { hovering in
            if hovering {
                NSCursor.resizeUpDown.push()
                
            } else {
                NSCursor.pop()
                
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<V: View>(_ condition: Bool, transform: (Self) -> V) -> some View {
        if condition { transform(self) } else { self }
    }
}
