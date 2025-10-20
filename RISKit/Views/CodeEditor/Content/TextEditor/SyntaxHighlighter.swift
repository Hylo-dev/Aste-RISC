//
//  SyntaxHighlighter.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//
import Foundation
import AppKit
import Highlightr
import STTextView

final class SyntaxHighlighter {
    static let shared = SyntaxHighlighter()
    private let highlightr: Highlightr
    
    private var lastHighlightTime: Date = .distantPast
    private let minTimeBetweenHighlights: TimeInterval = 0.25
    private var lastDiagnosticsSignature: Int = 0

    private init() {
        
        guard let highlightr = Highlightr() else {
            fatalError("Highlightr init failed")
        }
        
        self.highlightr = highlightr
        highlightr.setTheme(to: "atom-one-dark")
        highlightr.theme.setCodeFont(
            .monospacedSystemFont(
                ofSize: 14,
                weight: .regular
            )
        )
        
    }

    // func applyHighlight(textView: STTextView, diagnostics: [LSPDiagnostic])
    func applyHighlight(textView: STTextView) {

        if !Thread.isMainThread {
            Task {
                //self.applyHighlight(textView: textView, diagnostics: diagnostics)
                self.applyHighlight(textView: textView)
            }
            
            return
        }
        
//        let diagSig = diagnostics.reduce(into: 0) { partial, d in
//            partial = partial &* 31 &+ d.range.location &* 131 &+ d.range.length &+ severityScore(d.severity)
//        }
        
//        let now = Date()
//        let diagnosticsChanged = (diagSig != lastDiagnosticsSignature)
//        if !diagnosticsChanged && now.timeIntervalSince(lastHighlightTime) < minTimeBetweenHighlights {
//            return
//        }
//        lastDiagnosticsSignature = diagSig
//        lastHighlightTime = now

        guard let code = textView.text, !code.isEmpty else { return }
        
        _ = textView.selectedRange()
        let savedScrollOrigin = textView.enclosingScrollView?.contentView.bounds.origin ?? .zero

        let fullRange = NSRange(location: 0, length: (code as NSString).length)
        let defaultFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)

        textView.setAttributes([.font: defaultFont, .foregroundColor: NSColor.textColor], range: fullRange)
        
        if let highlighted = highlightr.highlight(code, as: "s") {
            
            highlighted.enumerateAttributes(
                in: NSRange(
                    location: 0,
                    length: min(highlighted.length, fullRange.length)
                ),
                options: []
                
            ) { attrs, range, _ in
                guard range.location + range.length <= fullRange.length else { return }
                var filteredAttrs: [NSAttributedString.Key: Any] = [:]
                
                if let color = attrs[.foregroundColor] {
                    filteredAttrs[.foregroundColor] = color
                }
                
                if !filteredAttrs.isEmpty {
                    textView.addAttributes(filteredAttrs, range: range)
                }
                
            }
        }

//        if !diagnostics.isEmpty {
//            let maxLen = (code as NSString).length
//            for diag in diagnostics {
//                var r = diag.range
//
//                if r.length == 0, r.location < maxLen {
//                    r.length = 1
//                }
//                guard r.location >= 0, r.location + r.length <= maxLen, r.length > 0 else { continue }
//                
//                let underlineColor: NSColor
//                switch diag.severity {
//                case .error: underlineColor = .systemRed
//                case .warning: underlineColor = .systemOrange
//                case .info, .hint: underlineColor = .systemBlue
//                }
//                
//                // Sottolineatura
//                textView.addAttributes([
//                    .underlineStyle: NSUnderlineStyle.single.rawValue as NSNumber,
//                    .underlineColor: underlineColor
//                ], range: r)
//                
//                
//            }
//        }

        if let sv = textView.enclosingScrollView {
            sv.contentView.scroll(to: savedScrollOrigin)
            sv.reflectScrolledClipView(sv.contentView)
        }
    }
}

//private func severityScore(_ s: LSPDiagnostic.Severity) -> Int {
//    switch s {
//    case .error: return 4
//    case .warning: return 3
//    case .info: return 2
//    case .hint: return 1
//    }
//}
