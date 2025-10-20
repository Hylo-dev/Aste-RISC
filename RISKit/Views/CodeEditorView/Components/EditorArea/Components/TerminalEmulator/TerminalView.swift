//
//  Terminal.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/10/25.
//

import SwiftUI
import SwiftTerm
import AppKit

struct TerminalView: NSViewRepresentable {
    let pathProgramExecute: String
    let args              : [String]
    let cornerRadiusActive: Bool
    
    init(
        pathProgramExecute: String,
        args              : [String] = [],
        cornerRadiusActive: Bool = true
    ) {
        self.pathProgramExecute = pathProgramExecute
        self.args               = args
        self.cornerRadiusActive = cornerRadiusActive
    }

    func makeCoordinator() -> CoordinatorTerminal { CoordinatorTerminal() }

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let term = LocalProcessTerminalView(frame: .zero)
        term.getTerminal().setCursorStyle(.steadyBlock)
        
        // Set color term
        term.caretColor           = .systemGreen
        term.caretViewTracksFocus = true
        term.processDelegate      = context.coordinator
        
        if cornerRadiusActive {
            // Corner radius on AppKit
            term.wantsLayer           = true
            term.layer?.cornerRadius  = 25
            term.layer?.masksToBounds = true
            
        } 
        return term
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        guard !context.coordinator.started else { return }
        context.coordinator.started = true

        Task {
            
            nsView.selectNone()

            nsView.startProcess(executable: pathProgramExecute, args: args)
            nsView.window?.makeFirstResponder(nsView)
            
            try await Task.sleep(for: .milliseconds(100))
            nsView.feed(text: "\u{1B}[?1000l\u{1B}[?1002l\u{1B}[?1006l")
            
        }
    }

    class CoordinatorTerminal: NSObject, LocalProcessTerminalViewDelegate {
        
        var started = false
        var mouseUpMonitor: Any?

        deinit {
            if let m = mouseUpMonitor {
                NSEvent.removeMonitor(m)
                mouseUpMonitor = nil
            }
        }

        func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {}
        func processTerminated(source: SwiftTerm.TerminalView, exitCode: Int32?) {}
        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}
        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}
        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
        func processTerminated(source: TerminalView, exitCode: Int32?) {
            print("Process terminated: \(String(describing: exitCode))")
        }
    }
}
