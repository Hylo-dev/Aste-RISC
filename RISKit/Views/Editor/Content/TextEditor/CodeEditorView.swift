import SwiftUI

struct CodeEditorView: View {
    @Binding var text               : String
    @Binding var indexInstruction   : UInt?
    @Binding var indexesInstructions: [Int]
    
    @StateObject private var viewModel: CodeEditorViewModel

    init(
        text               : Binding<String>,
        indexInstruction   : Binding<UInt?>,
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
//        .onAppear {
//            viewModel.setupLSP(language: language)
//        }
        .onChange(of: text) { _, newText in
            viewModel.textChanged(newText: newText)
        }
    }
}
