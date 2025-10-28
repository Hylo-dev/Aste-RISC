//
//  ThemeNativeEditor.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/10/25.
//

import SwiftUI
import Foundation

struct ThemeEditorsSettings: SettingsInterface {
    var fileName: String
    
    var id = UUID()
    
    init() { self.init(
        themeName: "",
        backgroundColor: "",
        selectionColor: "",
        currentLineColor: "",
        syntaxColor: SyntaxColorNativeEditor()
    ) }
    
    var backgroundColor : String
    var selectionColor  : String
    var currentLineColor: String
    var syntaxColor     : SyntaxColorNativeEditor
    
    init(
        themeName       : String,
        backgroundColor : String = "1E1E1E",
        selectionColor  : String = "3C3836",
        currentLineColor: String = "2A2826",
        syntaxColor     : SyntaxColorNativeEditor = SyntaxColorNativeEditor()
        
    ) {
        self.fileName = themeName
        
        self.backgroundColor  = backgroundColor
        self.selectionColor   = selectionColor
        self.currentLineColor = currentLineColor
        self.syntaxColor      = syntaxColor
    }
}
