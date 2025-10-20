import SwiftUI
import AppKit
import SwiftTerm

struct EditorAreaView: View {
//    @ObservedObject var compilerProfile: CompilerProfileStore
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    
    // Params struct
    @Binding var mapInstruction: MapInstructions
             var projectRoot   : URL
    
    // Internal var struct for UI
    @State private var terminalHeight : CGFloat = 200
    @State private var isBottomVisible: Bool    = true
    @State private var text           : String  = ""
           private let collapsedHeight: CGFloat = 48
            

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                
                if self.bodyEditorViewModel.editorState == .running {
                    CodeEditorView(
                        text: $text,
                        mapInstruction: $mapInstruction,
                        projectRoot: self.bodyEditorViewModel.currentFileSelected!,
                        pathFile: projectRoot
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: topHeight(totalHeight: geo.size.height),
                        alignment: .topLeading
                    )
                    
                } else {
                    Terminal(pathFile: self.bodyEditorViewModel.currentFileSelected!.path)
                       
                }
                                
                TerminalContainerView(
                    terminalHeight: $terminalHeight,
                    isBottomVisible: $isBottomVisible,
                    collapsedHeight: collapsedHeight
                )
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .animation(.spring(), value: isBottomVisible)
            .onChange(of: self.bodyEditorViewModel.currentFileSelected) { _, _ in loadSelectedFile() }
            .onAppear { loadSelectedFile() }
        }
    }
    
    private func loadSelectedFile() {
        self.text = (try? String(contentsOf: self.bodyEditorViewModel.currentFileSelected!, encoding: .utf8)) ?? ""
    }
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if isBottomVisible {
            let top = totalHeight - terminalHeight - 18
            return max(top, 40)
            
        } else {
            return totalHeight - collapsedHeight - 10
        }
    }
    
}

