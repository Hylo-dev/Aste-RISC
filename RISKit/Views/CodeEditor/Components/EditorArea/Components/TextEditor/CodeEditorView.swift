import SwiftUI

struct CodeEditorView: View {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    
    @StateObject private var viewModel: CodeEditorViewModel
    
    @Binding var text: String
        
    init(
        text               : Binding<String>,
        projectRoot        : URL,
        pathFile           : URL
    ) {
        
        // Bindings
        self._text = text
        
        // View model init
        self._viewModel = StateObject(wrappedValue: CodeEditorViewModel(projectRoot: projectRoot, documentURI: pathFile))
    }

    var body: some View {
        VStack {
            TextViewWrapper(
                text          : $text,
                viewModel     : viewModel,
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .padding()
        .background(roundedBackground)
//       .onAppear {
//           viewModel.setupLSP(language: language)
//       }
        .onChange(of: text) { _, newText in
            viewModel.textChanged(newText: newText)
        }
    }
    
    private var roundedBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
}
