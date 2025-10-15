import SwiftUI
import STTextView

struct CodeEditorView: View {
    @Binding var text: String
    var pathFile: URL
    var projectRoot: URL
    @StateObject private var viewModel: CodeEditorViewModel

    init(text: Binding<String>, projectRoot: URL, pathFile: URL) {
        self._text = text
        self.projectRoot = projectRoot
        self.pathFile = pathFile
        self._viewModel = StateObject(wrappedValue: CodeEditorViewModel(projectRoot: projectRoot, documentURI: pathFile))
    }

    var body: some View {
        VStack {
            TextViewWrapper(text: $text, viewModel: viewModel)
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
