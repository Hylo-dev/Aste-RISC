//
//  Terminal.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/10/25.
//

import SwiftUI
import SwiftTerm

struct Terminal: NSViewRepresentable {
    let pathFile: String
    
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let term = LocalProcessTerminalView(frame: .zero)
        term.getTerminal().setCursorStyle(.steadyBlock)
        term.caretColor = .systemGreen
        
        term.caretViewTracksFocus = true

        return term
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {

        if !context.coordinator.started {
            context.coordinator.started = true
            Task {
                nsView.selectNone()
                
                nsView.startProcess(executable: "/opt/homebrew/bin/hx", args: [pathFile])
                
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var started = false
    }
}
