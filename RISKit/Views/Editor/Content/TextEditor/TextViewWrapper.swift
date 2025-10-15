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
    @Binding var text: String
    var viewModel: CodeEditorViewModel
//    var language: Language

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = viewModel.createTextView(text: text)

        if let textView = scrollView.documentView as? STTextView {
            textView.textDelegate = context.coordinator
            context.coordinator.textView = textView
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? STTextView else { return }

        if textView.textDelegate == nil {
            textView.textDelegate = context.coordinator
        }

        context.coordinator.textView = textView

        if textView.text != text && !context.coordinator.isUpdatingText {
            context.coordinator.updateTextPreservingSelection(newText: text)
        }
    }

    class Coordinator: NSObject, STTextViewDelegate {
        var parent: TextViewWrapper
        weak var textView: STTextView?
        var isUpdatingText = false
        var lastString = ""

        init(_ parent: TextViewWrapper) { self.parent = parent }

        func textView(_ textView: STTextView, didChangeTextIn affectedRange: NSTextRange, replacementString: String) {
            guard let newText = textView.text else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.isUpdatingText { return }
                
                self.isUpdatingText = true
                defer { self.isUpdatingText = false }

                if self.parent.text != newText {
                    self.parent.text = newText
                    self.parent.viewModel.textChanged(newText: newText)
                }
                self.lastString = newText

//                self.parent.viewModel.handleCompletionInput()
            }
        }

        func updateTextPreservingSelection(newText: String) {
            guard let textView = textView else { return }

            isUpdatingText = true
            defer { isUpdatingText = false }

            let selectedRange = textView.selectedRange()
            let scrollPosition = textView.enclosingScrollView?.contentView.bounds.origin ?? .zero

            textView.text = newText
            
            let nsNewText = newText as NSString
            let newLen = nsNewText.length
            let location = min(selectedRange.location, newLen)
            let length = min(selectedRange.length, max(0, newLen - location))
            let safeRange = NSRange(location: location, length: length)
            
            textView.insertText("", replacementRange: safeRange)

            if let sv = textView.enclosingScrollView {
                sv.contentView.scroll(to: scrollPosition)
                sv.reflectScrolledClipView(sv.contentView)
            }

            lastString = newText
        }
        
        func textView(_ textView: STTextView, shouldHandleKeyDown event: NSEvent) -> Bool {
            
            if parent.viewModel.completionPopover?.isShown == true {
                
                switch event.keyCode {
                case 53: // Escape
                    return parent.viewModel.dismissCompletionIfNeeded()
                    
                case 36: // Return
                    parent.viewModel.confirmCurrentCompletion()
                    return true
                    
                case 125: // Arrow Down
                    parent.viewModel.moveCompletionSelection(by: 1)
                    return true
                    
                case 126: // Arrow Up
                    parent.viewModel.moveCompletionSelection(by: -1)
                    return true
                    
                case 48: // Tab
                    parent.viewModel.confirmCurrentCompletion()
                    return true
                    
                default:
                    if let chars = event.charactersIgnoringModifiers,
                       [" ", ";", "(", ")", "{", "}", "[", "]"].contains(chars) {
                        _ = parent.viewModel.dismissCompletionIfNeeded()
                    }
                    return false
                }
            }
            
            if event.keyCode == 36 { // Return key for auto-indentation
                
                let currentRange = textView.selectedRange()
                
                guard let fullText = textView.text else { return false }
                let full = fullText as NSString
                
                let actualLineRange = full.lineRange(for: NSRange(location: currentRange.location, length: 0))
                let currentLine = full.substring(with: actualLineRange)

                var indentation = ""
                for ch in currentLine {
                    if ch == " " || ch == "\t" {
                        indentation.append(ch)
                    } else {
                        break
                    }
                }

                let insertText = "\n" + indentation
                textView.insertText(insertText, replacementRange: currentRange)

                let newLocation = currentRange.location + (insertText as NSString).length
                textView.insertText("", replacementRange: NSRange(location: newLocation, length: 0))
                
                return true
            }
            
            return false
        }
    }
}
