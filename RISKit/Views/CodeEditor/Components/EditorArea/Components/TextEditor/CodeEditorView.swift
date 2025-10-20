import SwiftUI

struct CodeEditorView: View {
    @StateObject private var codeEditorViewModel: CodeEditorViewModel
    
    @Binding private var text: String
        
    init(
        text       : Binding<String>,
        projectRoot: URL,
        pathFile   : URL
    ) {
        self._text = text
        
        self._codeEditorViewModel = StateObject(
            wrappedValue: CodeEditorViewModel(
                projectRoot: projectRoot,
                documentURI: pathFile
            )
        )
    }

    var body: some View {
        VStack {
            TextViewWrapper(text: $text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(self.codeEditorViewModel)
            
        }
        .padding()
        .background(roundedBackground)
        .onChange(of: text) { _, newText in codeEditorViewModel.textChanged(newText: newText) }
    }
    
    private var roundedBackground: some View {
        return RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
}
