import SwiftUI

struct EditorAreaView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    
    // Internal var struct for UI
    @State private var text           : String  = ""
    @State private var terminalHeight : CGFloat = 200
    @State private var isBottomVisible: Bool    = true
           
    private static let collapsedHeight: CGFloat = 48
    
    var projectRoot: URL // Principal path, this is project path
            
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                
                if self.bodyEditorViewModel.editorState == .running {
                    CodeEditorView(
                        text       : $text,
                        projectRoot: projectRoot,
                        pathFile   : self.bodyEditorViewModel.currentFileSelected!
                    )
                    .frame(
                        maxWidth : .infinity,
                        maxHeight: topHeight(totalHeight: geo.size.height),
                        alignment: .topLeading
                    )
                    
                } else {
                    EditorTerminalView(openFilePath: self.bodyEditorViewModel.currentFileSelected!.path)
                       
                }
                                
                TerminalContainerView(
                    terminalHeight:  $terminalHeight,
                    isBottomVisible: $isBottomVisible,
                )
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .animation(.spring(), value: isBottomVisible)
            .onChange(of: self.bodyEditorViewModel.currentFileSelected, handleFileSelected)
            .onAppear { handleFileSelected(oldValue: nil, newValue: nil) }
        }
    }
    
    private func handleFileSelected(oldValue: URL?, newValue: URL?) {
        self.text = (try? String(contentsOf: self.bodyEditorViewModel.currentFileSelected!, encoding: .utf8)) ?? ""
    }
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if isBottomVisible {
            let top = totalHeight - terminalHeight - 18
            return max(top, 40)
            
        } else {
            return totalHeight - Self.collapsedHeight - 10
        }
    }
    
}

