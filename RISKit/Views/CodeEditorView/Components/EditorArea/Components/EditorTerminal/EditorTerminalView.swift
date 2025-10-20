//
//  EditorTerminalView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/10/25.
//

import SwiftUI

struct EditorTerminalView: View {
    let openFilePath: String
    
    var body: some View {
        
        TerminalView(
            pathProgramExecute: "/opt/homebrew/bin/hx",
            args              : [openFilePath]
        )
    }
}
