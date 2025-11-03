import SwiftUI

struct EditorAreaView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
	
    // Internal var struct for UI
    @State private var codeEditorDocument: CodeEditSourceEditorDocument = CodeEditSourceEditorDocument()
    @State private var terminalHeight    : CGFloat = 200
           
    private static let collapsedHeight: CGFloat = 48
    
	@Binding private var fileSelected: URL?
	
    var projectRoot: URL // Principal path, this is project path
	let editorUse  : Editors
	
	init (
		projectRoot : URL,
		editorUse   : Editors,
		fileSelected: Binding<URL?>
	) {
		self.projectRoot   = projectRoot
		self.editorUse     = editorUse
		self._fileSelected = fileSelected
	}
            
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
				
				switch editorUse {
					case .native:
						CodeSourceEditorView(document: $codeEditorDocument)
							.frame(
								maxWidth : .infinity,
								maxHeight: topHeight(totalHeight: geo.size.height),
								alignment: .topLeading
							)
						
						
					case .helix, .vim, .nvim:
						if self.bodyEditorViewModel.editorState == .running {
							CodeSourceEditorView(document: $codeEditorDocument)
								.frame(
									maxWidth : .infinity,
									maxHeight: topHeight(totalHeight: geo.size.height),
									alignment: .topLeading
								)
							
						} else { // self.bodyEditorViewModel.currentFileSelected!.path
							EditorTerminalView(openFilePath: self.fileSelected!.path)
							
						}
				}
				
                TerminalContainerView(
					isOutputVisible: self.$bodyEditorViewModel.isOutputVisible,
					terminalHeight: $terminalHeight
				)
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
			.animation(.spring(), value: self.bodyEditorViewModel.isOutputVisible)
            // Set file selected to editor text self.bodyEditorViewModel.currentFileSelected
			.onChange(of: self.fileSelected, handleFileSelected)
            .onAppear { handleFileSelected(oldValue: nil, newValue: nil) }
        }
    }
    
	private func handleFileSelected(oldValue: URL?, newValue: URL?) {
		// self.bodyEditorViewModel.currentFileSelected
		guard let url = self.fileSelected else {
			return
		}

		let fileString = (try? String(contentsOf: url, encoding: .utf8)) ?? ""

		Task { @MainActor in
			if self.codeEditorDocument.text.string != fileString {
				self.codeEditorDocument.text.setAttributedString(NSAttributedString(string: fileString))
			}
		}
	}
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if self.bodyEditorViewModel.isOutputVisible {
            let top = totalHeight - terminalHeight - 18
			
            return max(top, 40)
        } else {  return totalHeight - Self.collapsedHeight - 10 }
    }
    
}

