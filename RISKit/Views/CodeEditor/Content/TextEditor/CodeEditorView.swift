import SwiftUI

struct CodeEditorView: View {
    @Binding var text          : String
    @Binding var mapInstruction: MapInstructions
        
    @StateObject private var viewModel: CodeEditorViewModel

    init(
        text               : Binding<String>,
        mapInstruction     : Binding<MapInstructions>,
        projectRoot        : URL,
        pathFile           : URL
    ) {
        
        // Bindings
        self._text                = text
        self._mapInstruction    = mapInstruction
        
        // View model init
        self._viewModel = StateObject(wrappedValue: CodeEditorViewModel(projectRoot: projectRoot, documentURI: pathFile))
    }

    var body: some View {
        VStack {
            TextViewWrapper(
                text          : $text,
                mapInstruction: $mapInstruction,
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
