import SwiftUI
import AppKit

struct ContextView: View {
//    @ObservedObject var compilerProfile: CompilerProfileStore
                   var projectRoot    : URL
    
    @State private var terminalHeight : CGFloat = 200
    @State private var isBottomVisible: Bool    = true
    @State private var text           : String  = ""
    
           private let collapsedHeight: CGFloat = 48
                   let selectedFile   : URL

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                
                VStack {
                    CodeEditorView(
                        text: $text,
//                        compilerProfile: compilerProfile,
                        projectRoot: projectRoot,
                        pathFile: selectedFile
                    )
                    
                    Spacer()
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: topHeight(totalHeight: geo.size.height),
                    alignment: .topLeading
                )
                .background(roundedBackground)
                
                TerminalView(terminalHeight: $terminalHeight, isBottomVisible: $isBottomVisible, collapsedHeight: collapsedHeight)
                
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .animation(.spring(), value: isBottomVisible)
            .onChange(of: selectedFile) { _, _ in
                loadSelectedFile()
            }
            .onAppear {
                loadSelectedFile()
            }
        }
    }
    
    private func loadSelectedFile() {
        text = (try? String(contentsOf: selectedFile, encoding: .utf8)) ?? ""
    }
    
    private func topHeight(totalHeight: CGFloat) -> CGFloat {
        if isBottomVisible {
            let top = totalHeight - terminalHeight - 18
            return max(top, 40)
        } else {
            return totalHeight - collapsedHeight - 10
        }
    }
    
    private var roundedBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
}

