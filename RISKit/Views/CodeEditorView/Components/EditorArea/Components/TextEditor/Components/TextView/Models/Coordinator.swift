//
//  Coordinator.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

import SwiftUI
import STTextView

class Coordinator: NSObject, STTextViewDelegate {
    @EnvironmentObject private var codeEditorViewModel: CodeEditorViewModel
    
    var parent: TextViewWrapper
    weak var textView: STTextView?
    var isUpdatingText = false
    var lastString = ""

    init(_ parent: TextViewWrapper) { self.parent = parent }

    func textView(_ textView: STTextView, didChangeTextIn affectedRange: NSTextRange, replacementString: String) {
        guard let newText = textView.text else { return }

        Task { [weak self] in
            guard let self = self else { return }
            
            if self.isUpdatingText { return }
            
            self.isUpdatingText = true
            defer { self.isUpdatingText = false }

            if self.parent.text != newText {
                self.parent.text = newText
                
            }
            self.lastString = newText

//          self.parent.codeEditorViewModel.handleCompletionInput()
        }
    }
    
    func highlightLine(at index: Int = 0, clear isCleaning: Bool = false) {
        guard let textView = textView, let text = textView.text else { return }
        let nsText = text as NSString

        // Resetta tutti i colori a default (bianco/nero, ecc.)
        let fullRange = NSRange(location: 0, length: nsText.length)
        let defaultColor = textView.backgroundColor ?? NSColor.textBackgroundColor
        textView.addAttributes([.backgroundColor: defaultColor], range: fullRange)

        if !isCleaning {
            // Calcola linee
            var lineStart = 0
            var lineEnd = 0
            var contentsEnd = 0
            var currentLine: UInt = 0

            while lineStart < nsText.length {
                nsText.getLineStart(&lineStart, end: &lineEnd, contentsEnd: &contentsEnd, for: NSRange(location: lineStart, length: 0))

                if currentLine == index {
                    let highlightRange = NSRange(location: lineStart, length: lineEnd - lineStart)
                    textView.addAttributes([.backgroundColor: NSColor.selectedTextBackgroundColor], range: highlightRange)
                    textView.scrollRangeToVisible(highlightRange)
                    break
                }

                currentLine += 1
                lineStart = lineEnd
            }
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
        
        if codeEditorViewModel.completionPopover?.isShown == true {
            
            switch event.keyCode {
            case 53: // Escape
                return codeEditorViewModel.dismissCompletionIfNeeded()
                
            case 36: // Return
                codeEditorViewModel.confirmCurrentCompletion()
                return true
                
            case 125: // Arrow Down
                codeEditorViewModel.moveCompletionSelection(by: 1)
                return true
                
            case 126: // Arrow Up
                codeEditorViewModel.moveCompletionSelection(by: -1)
                return true
                
            case 48: // Tab
                codeEditorViewModel.confirmCurrentCompletion()
                return true
                
            default:
                if let chars = event.charactersIgnoringModifiers,
                   [" ", ";", "(", ")", "{", "}", "[", "]"].contains(chars) {
                    _ = codeEditorViewModel.dismissCompletionIfNeeded()
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
