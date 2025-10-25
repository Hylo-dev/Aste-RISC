import SwiftUI

struct EditorAreaView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
	
    // Internal var struct for UI
    @State private var text           : CodeEditSourceEditorDocument = CodeEditSourceEditorDocument()
    @State private var terminalHeight : CGFloat = 200
           
    private static let collapsedHeight: CGFloat = 48
    
    var projectRoot: URL // Principal path, this is project path
	let editorUse  : Editors
	
	init (projectRoot: URL, editorUse: Editors) {
		self.projectRoot = projectRoot
		self.editorUse   = editorUse
	}
            
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
				
				switch editorUse {
					case .native:
//						CodeEditorView(
//							text       : $text,
//							projectRoot: projectRoot,
//							pathFile   : self.bodyEditorViewModel.currentFileSelected!
//						)
//						.frame(
//							maxWidth : .infinity,
//							maxHeight: topHeight(totalHeight: geo.size.height),
//							alignment: .topLeading
//						)
						CodeEditorNewView(document: $text, fileURL: self.bodyEditorViewModel.currentFileSelected)
							.frame(
								maxWidth : .infinity,
								maxHeight: topHeight(totalHeight: geo.size.height),
								alignment: .topLeading
							)
						
						
					case .helix, .vim, .nvim:
						if self.bodyEditorViewModel.editorState == .running {
//							CodeEditorView(
//								text       : $text,
//								projectRoot: projectRoot,
//								pathFile   : self.bodyEditorViewModel.currentFileSelected!
//							)
							CodeEditorNewView(document: $text, fileURL: self.bodyEditorViewModel.currentFileSelected)
								.frame(
									maxWidth : .infinity,
									maxHeight: topHeight(totalHeight: geo.size.height),
									alignment: .topLeading
								)
							
						} else {
							EditorTerminalView(openFilePath: self.bodyEditorViewModel.currentFileSelected!.path)
							
						}
				}
				
                TerminalContainerView(terminalHeight: $terminalHeight)
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
			.animation(.spring(), value: self.bodyEditorViewModel.isOutputVisible)
            .onChange(of: self.bodyEditorViewModel.currentFileSelected, handleFileSelected)
            .onAppear { handleFileSelected(oldValue: nil, newValue: nil) }
        }
    }
    
	private func handleFileSelected(oldValue: URL?, newValue: URL?) {
		guard let url = self.bodyEditorViewModel.currentFileSelected else {
			return
		}

		let fileString = (try? String(contentsOf: url, encoding: .utf8)) ?? ""

		Task {
			if self.text.text.string != fileString {
				self.text.text.setAttributedString(NSAttributedString(string: fileString))
			}
		}
	}
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if self.bodyEditorViewModel.isOutputVisible {
            let top = totalHeight - terminalHeight - 18
            return max(top, 40)
            
        } else {
            return totalHeight - Self.collapsedHeight - 10
        }
    }
    
}

