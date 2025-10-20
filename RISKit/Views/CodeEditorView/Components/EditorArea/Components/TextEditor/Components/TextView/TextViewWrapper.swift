//
//  TextViewWrapper.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

import SwiftUI
import AppKit
import STTextView

struct TextViewWrapper: NSViewRepresentable {
    @EnvironmentObject private var bodyEditorViewModel: BodyEditorViewModel
    @EnvironmentObject private var codeEditorViewModel: CodeEditorViewModel
    
    @Binding var text: String

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = codeEditorViewModel.createTextView(text: text)

        if let textView = scrollView.documentView as? STTextView {
            textView.textDelegate = context.coordinator
            context.coordinator.textView = textView
            
            textView.isEditable   = self.bodyEditorViewModel.mapInstruction.indexInstruction == nil
            textView.isSelectable = true
            
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? STTextView else { return }
        let mapInstruction = bodyEditorViewModel.mapInstruction
        
        textView.isEditable   = self.bodyEditorViewModel.mapInstruction.indexInstruction == nil
        textView.isSelectable = true

        if textView.textDelegate == nil { textView.textDelegate = context.coordinator }

        context.coordinator.textView = textView

        if textView.text != text && !context.coordinator.isUpdatingText {
            context.coordinator.updateTextPreservingSelection(newText: text)
        }
            
        if mapInstruction.indexInstruction != nil &&
           !mapInstruction.indexesInstructions.isEmpty &&
           mapInstruction.indexInstruction! <= mapInstruction.indexesInstructions.count
        {
            context.coordinator.highlightLine(
                at: mapInstruction.indexesInstructions[Int(mapInstruction.indexInstruction ?? 0)]
            )
            
        } else {
            context.coordinator.highlightLine(clear: true)
            
        }
        
        self.codeEditorViewModel.scheduleHighlight()
    }
}
