//
//  EditorSettingView.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/10/25.
//

import SwiftUI

struct EditorSettingView: View {
    let settingsManager: SettingsManager
    
    @State private var editorUse     : Editors               = .native
	@State private var globalSettings: GlobalSettings?		 = nil
    @State private var currentTheme  : ThemeEditorsSettings? = nil
    
    var body: some View {
        
        Form {
            
            Section("Editor Type") {
                Picker("Editor", selection: $editorUse) {
                    
                    ForEach(Editors.allCases, id: \.id) { editor in
                        Text(editor.rawValue).tag(editor)
                    }
                }
                
            }
            
            Section("Editor settings") {
                Text("Test")
            }
            
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: handleFormAppear)
		.onChange(of: self.editorUse, handleEditorSelectedChange)
    }
	
	private func handleEditorSelectedChange(
		oldValue: Editors,
		newValue: Editors
		
	) {
		if newValue != oldValue {
			
			self.globalSettings?.editorUse = self.editorUse
			
			self.settingsManager.save(self.globalSettings!)
		}
		
	}
    
    private func handleFormAppear() {
		
        if let globalSettings = self.settingsManager.load(
            file: "global_settings.json",
            GlobalSettings.self
        ) {
			self.globalSettings = globalSettings
            self.editorUse 	 	= globalSettings.editorUse
			     
            if let theme = settingsManager.load(
                folder: "Themes",
                file: globalSettings.themeUsed,
                ThemeEditorsSettings.self
                
            ) {
                self.currentTheme = theme
            }
        }
    }
}
