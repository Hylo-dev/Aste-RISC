import SwiftUI
import AppKit
import SwiftTerm

struct ContextView: View {
//    @ObservedObject var compilerProfile: CompilerProfileStore
    
    // Params struct
    @Binding var indexInstruction   : UInt32?
    @Binding var indexesInstructions: [Int]
    @Binding var editorStatus       : EditorStatus
             var projectRoot        : URL
             let selectedFile       : URL
    
    // Internal var struct for UI
    @State private var terminalHeight : CGFloat = 200
    @State private var isBottomVisible: Bool    = true
    @State private var text           : String  = ""
           private let collapsedHeight: CGFloat = 48
            

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                
                if editorStatus == EditorStatus.running {
                    CodeEditorView(
                        text: $text,
                        indexInstruction: $indexInstruction,
                        indexesInstructions: $indexesInstructions,
                        projectRoot: selectedFile,
                        pathFile: projectRoot
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: topHeight(totalHeight: geo.size.height),
                        alignment: .topLeading
                    )
                    
                } else {
                    Terminal(pathFile: selectedFile.path)
                       
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
            .onChange(of: selectedFile) { _, _ in loadSelectedFile() }
            .onAppear { loadSelectedFile() }
        }
    }
    
    private func loadSelectedFile() { self.text = (try? String(contentsOf: selectedFile, encoding: .utf8)) ?? "" }
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if isBottomVisible {
            let top = totalHeight - terminalHeight - 18
            return max(top, 40)
            
        } else {
            return totalHeight - collapsedHeight - 10
        }
    }
    
}

