//
//  NavigatiorAreaView.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 03/11/25.
//

import SwiftUI

struct NavigatiorAreaView: View {
	
	/// Current file modified in editor view
	@Binding
	private var fileSelected: URL?
	
	/// Project path
	private let projectPath: String
	
	init(
		fileSelected: Binding<URL?>,
		projectPath : String
	) {
		self._fileSelected = fileSelected
		self.projectPath   = projectPath
	}
	
	var body: some View {
		
		VStack {
			TreeFilesView(
				projectPath : self.projectPath,
				selectedFile: self.$fileSelected
				
			) { newURL in self.fileSelected = newURL } // Change file opened
			
			Spacer()
			
		}
		.padding(.horizontal, 10)
	}
}
