import SwiftUI

struct CodeEditorView: View {
    @Binding var text               : String
    @Binding var indexInstruction   : UInt32?
    @Binding var indexesInstructions: [Int]
        
    @StateObject private var viewModel: CodeEditorViewModel

    init(
        text               : Binding<String>,
        indexInstruction   : Binding<UInt32?>,
        indexesInstructions: Binding<[Int]>,
        projectRoot        : URL,
        pathFile           : URL
    ) {
        
        // Bindings
        self._text                = text
        self._indexInstruction    = indexInstruction
        self._indexesInstructions = indexesInstructions
        
        // View model init
        self._viewModel = StateObject(wrappedValue: CodeEditorViewModel(projectRoot: projectRoot, documentURI: pathFile))
    }

    var body: some View {
        VStack {
            TextViewWrapper(
                text              : $text,
                indexInstruction  : $indexInstruction,
                indexesIstructions: $indexesInstructions,
                viewModel         : viewModel,
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
