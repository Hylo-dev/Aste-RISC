//
//  CodeEditorViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

import Foundation
import AppKit
internal import Combine
import SwiftUI
import STTextView

final class CodeEditorViewModel: ObservableObject {
//    @Published private(set) var diagnostics: [LSPDiagnostic] = []

    let projectRoot: URL
    let documentURI: URL

    // Core components
    private weak var textView: STTextView?
    private weak var scrollView: NSScrollView?
//    private var lspClient: LSPClient?
    private var cancellables = Set<AnyCancellable>()
    private var lastVersion: Int = 1
    private var didOpenSent = false

    // Performance optimization - use single queue for all debouncing
    private let workQueue = DispatchQueue(label: "com.editor.workQueue", qos: .userInitiated)
    private var pendingWorkItems: [String: DispatchWorkItem] = [:]
    
    // Completion system - NOT weak to ensure it stays alive
    internal var completionPopover: NSPopover?
    private var currentCompletionItems: [CompletionItem] = []
    private var currentCompletionSelection: Int = 0
    private var completionWordStart: Int = 0
    
    private var keyEventMonitor: Any?
    private var isInsertingCompletion = false

    // Constants for timing
    private enum Delays {
        static let highlight: TimeInterval = 0.12
        static let highlightResponsive: TimeInterval = 0.18
        static let completion: TimeInterval = 0.05
    }

    init(projectRoot: URL, documentURI: URL) {
        self.projectRoot = projectRoot
        self.documentURI = documentURI
    }
    
    deinit {
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        cancelAllPendingWork()
        cancellables.removeAll()
    }

//    func setupLSP(language: Language) {
//        lspClient = LSPClient()
//        try? lspClient?.start(projectRoot: projectRoot)
//
//        NotificationCenter.default.publisher(for: .lspDiagnosticsReceived)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] notification in
//                self?.handleDiagnostics(notification)
//            }
//            .store(in: &cancellables)
//        
//        lspClient?.onInitialized = { [weak self] in
//            self?.openDocumentIfReady()
//        }
//    }
    
    private func cancelAllPendingWork() {
        pendingWorkItems.values.forEach { $0.cancel() }
        pendingWorkItems.removeAll()
    }
    
    private func cancelPendingWork(for key: String) {
        pendingWorkItems[key]?.cancel()
        pendingWorkItems.removeValue(forKey: key)
    }
    
    private func scheduleWork(for key: String, delay: TimeInterval, work: @escaping () -> Void) {
        cancelPendingWork(for: key)
        
        let workItem = DispatchWorkItem { [weak self] in
            work()
            self?.pendingWorkItems.removeValue(forKey: key)
        }
        
        pendingWorkItems[key] = workItem
        workQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    private func openDocumentIfReady() {
        guard !didOpenSent,
//            let lsp = lspClient,
            let tv = textView,
            let _ = tv.text else { return }

//        lsp.openDocument(uri: documentURI.absoluteString, languageId: Language.c.langId, text: text)
        didOpenSent = true
    }

    func textChanged(newText: String) {
//        guard let lsp = lspClient else { return }

//        lastVersion += 1
//        let version = lastVersion
        
//        lsp.changeDocument(uri: documentURI.absoluteString, text: newText, version: version)
//
//        let shouldForceHighlight = !diagnostics.isEmpty
//        if shouldForceHighlight {
//            self.diagnostics = []
//        }
//        
//        scheduleHighlight(force: shouldForceHighlight)
    }

    private func handleDiagnostics(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let params = obj["params"] as? [String: Any],
              let uri = params["uri"] as? String,
              uri == documentURI.absoluteString else {
            return
        }
        
//        let diagnosticsArray = params["diagnostics"] as? [[String: Any]] ?? []
//        let currentText = textView?.text ?? ""
//        let parsedDiagnostics = diagnosticsArray.compactMap { LSPDiagnostic(from: $0, inText: currentText) }
        
        // Check if diagnostics have changed without using Equatable
//        let diagnosticsChanged = isDiagnosticsListChanged(old: diagnostics, new: parsedDiagnostics)
//        if diagnosticsChanged {
//            self.diagnostics = parsedDiagnostics
//            scheduleHighlight(force: true)
//        }
    }
    
    // Manual check for diagnostics changes without requiring Equatable conformance
//    private func isDiagnosticsListChanged(old: [LSPDiagnostic], new: [LSPDiagnostic]) -> Bool {
//        if old.count != new.count {
//            return true
//        }
//        
//        // If there are diagnostics, just force a refresh to be safe
//        if !new.isEmpty {
//            return true
//        }
//        
//        return false
//    }

    func scheduleHighlight(force: Bool = false) {
        let captureVersion = lastVersion
        
        Task { [weak self] in
            guard let self = self,
                  let textView = self.textView,
                  force || self.lastVersion == captureVersion else { return }
            
            //SyntaxHighlighter.shared.applyHighlight(textView: tv, diagnostics: captureDiagnostics)
            SyntaxHighlighter.shared.applyHighlight(textView: textView)
        }
    }

    func createTextView(text: String) -> NSScrollView {
        if let existing = scrollView {
            updateTextView(existing, text: text)
            return existing
        }

        let sv = STTextView.scrollableTextView()
        guard let tv = sv.documentView as? STTextView else {
            fatalError("Could not create STTextView")
        }

        configureTextView(tv, withText: text)
        textView = tv
        scrollView = sv

//        if let lsp = lspClient {
//            lastVersion = 1
//            lsp.openDocument(uri: documentURI.absoluteString, languageId: Language.c.langId, text: text)
//            didOpenSent = true
//        }

        scheduleHighlight()
        return sv
    }
    
    private func configureTextView(_ tv: STTextView, withText text: String) {
        tv.isEditable = true
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.allowsUndo = true
        tv.backgroundColor = .clear
        tv.textColor = NSColor.textColor
        tv.text = text
        tv.textContainer.widthTracksTextView = true
        tv.isHorizontallyResizable = false
        tv.isVerticallyResizable = true
        tv.autoresizingMask = [.width]
        tv.showsLineNumbers = true
        tv.highlightSelectedLine = true
        
        setupKeyEventHandler(for: tv)
    }

    func updateTextView(_ scrollView: NSScrollView, text: String) {
        guard let tv = scrollView.documentView as? STTextView else { return }
        if tv.text == text { return }

        let selectedRange = tv.selectedRange()
        let scrollPosition = scrollView.contentView.bounds.origin

        // Update text efficiently
        tv.text = text
        
        // Preserve selection safely
        let nsNewText = text as NSString
        let newLen = nsNewText.length
        let location = min(selectedRange.location, newLen)
        let length = min(selectedRange.length, max(0, newLen - location))
        let safeRange = NSRange(location: location, length: length)
        
        // Use insertText with empty string to set the selection range
        tv.insertText("", replacementRange: safeRange)

        // Preserve scroll position
        scrollView.contentView.scroll(to: scrollPosition)
        scrollView.reflectScrolledClipView(scrollView.contentView)

        self.textView = tv
        scheduleHighlight()
    }

    // MARK: - Optimized Completion System

//    func handleCompletionInput() {
//        guard !isInsertingCompletion else { return }
//        
//        scheduleWork(for: "completion", delay: Delays.completion) { [weak self] in
//            DispatchQueue.main.async {
//                self?.requestCompletions()
//            }
//        }
//    }

//    private func requestCompletions() {
//        guard let tv = textView, let fullText = tv.text else { return }
//        
//        let caret = tv.selectedRange().location
//        let currentWord = getCurrentWordAtCaret(text: fullText, caret: caret)
//        
//        let containsCodeCharacters = currentWord.contains { char in
//            CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).contains(char.unicodeScalars.first!)
//        }
//        
//        if currentWord.isEmpty || !containsCodeCharacters {
//            hideCompletionPopover()
//            return
//        }
//        
//        requestCompletionsFromLSP(at: caret, currentWord: currentWord)
//    }

    private func getCurrentWordAtCaret(text: String, caret: Int) -> String {
        let nsText = text as NSString
        let safeCaretPosition = min(caret, nsText.length)
        
        // Find the start of the current word (going backwards from caret)
        let beforeCaret = NSRange(location: 0, length: safeCaretPosition)
        let wordStartRange = nsText.rangeOfCharacter(
            from: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).inverted,
            options: .backwards,
            range: beforeCaret
        )
        
        completionWordStart = (wordStartRange.location == NSNotFound) ? 0 : wordStartRange.location + 1
        
        // Get just the word from start to caret
        let wordLength = safeCaretPosition - completionWordStart
        
        if wordLength > 0 {
            return nsText.substring(with: NSRange(location: completionWordStart, length: wordLength))
        }
        
        return ""
    }

//    private func requestCompletionsFromLSP(at caret: Int, currentWord: String) {
//        guard let tv = textView, let fullText = tv.text else { return }
//
//        let lineAndChar = calculateLineAndCharPosition(fullText: fullText, offset: caret)
//        guard lineAndChar.character >= 0 else { return }
//
////        lspClient?.requestCompletions(uri: documentURI.absoluteString, line: lineAndChar.line, character: lineAndChar.character) { [weak self] lspItems in
////            guard let self = self else { return }
////
////            // map -> CompletionItem and filter/score
////            let mapped = self.processCompletionItems(lspItems, currentWord: currentWord)
////
////            DispatchQueue.main.async {
////                self.currentCompletionItems = mapped
////                self.showOrUpdateCompletions()
////            }
////        }
//    }

    
//    private func calculateLineAndCharPosition(fullText: String, offset: Int) -> (line: Int, character: Int) {
//        let prefix = (fullText as NSString).substring(to: min(offset, fullText.count))
//        let line = prefix.components(separatedBy: "\n").count - 1
//        let startOfLineOffset = fullText.utf16OffsetOfLineStart(line)
//        let character = offset - startOfLineOffset
//        
//        return (line, character)
//    }
    
//    private func processCompletionItems(_ items: [LSPCompletionItem], currentWord: String) -> [CompletionItem] {
//        let lowerCurrent = currentWord.lowercased()
//
//        let transformed: [(CompletionItem, Bool, Int)] = items.compactMap { lsp in
//            let raw = lsp.bestInsertText ?? lsp.label
//            let cleaned = raw.replacingOccurrences(of: "•", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//            guard !cleaned.isEmpty else { return nil }
//
//            let lower = cleaned.lowercased()
//            guard lower.hasPrefix(lowerCurrent) else { return nil }
//
//            let exactCaseMatch = cleaned.hasPrefix(currentWord)
//            let length = cleaned.count
//            let comp = CompletionItem(from: lsp) // usa il tuo init
//            return (comp, exactCaseMatch, length)
//        }
//
//        let sorted = transformed.sorted { a, b in
//            if a.1 != b.1 { return a.1 && !b.1 }
//            return a.2 < b.2
//        }
//
//        return sorted.map { $0.0 }
//    }

    private func showOrUpdateCompletions() {
        if currentCompletionItems.isEmpty {
            hideCompletionPopover()
            return
        }
        
        currentCompletionSelection = 0
        
        if completionPopover?.isShown == true {
            updateCompletionPopover()
            updatePopoverPosition()
            
        } else {
            showCompletionPopover()
        }
    }

    private func updateCompletionPopover() {
        guard let popover = completionPopover else { return }
        
        let contentView = CompletionListView(
            items: currentCompletionItems,
            onSelect: { [weak self] selection in
                self?.insertCompletion(selection)
                self?.hideCompletionPopover()
            },
            onDismiss: { [weak self] in self?.hideCompletionPopover() }
            
        )
        
        let hostingController = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingController
    }

    private func updatePopoverPosition() {
        guard let tv = textView,
              let window = tv.window,
              let popover = completionPopover,
              popover.isShown else { return }
        
        let popoverRect = getPopoverRect(in: tv, window: window)
        popover.show(relativeTo: popoverRect, of: tv, preferredEdge: .maxY)
    }
    
    private func getPopoverRect(in textView: STTextView, window: NSWindow) -> NSRect {
        let caret = textView.selectedRange().location
        let range = NSRange(location: caret, length: 0)
        let characterRect = textView.firstRect(forCharacterRange: range, actualRange: nil)
        let windowRect = window.convertFromScreen(characterRect)
        let textViewRect = textView.convert(windowRect, from: nil)
        
        return NSRect(
            x: textViewRect.origin.x,
            y: textViewRect.origin.y - 2,
            width: 1,
            height: textViewRect.height
        )
    }

    private func showCompletionPopover() {
        guard let tv = textView, let window = tv.window, !currentCompletionItems.isEmpty else {
            return
        }

        // Create content view
        let contentView = CompletionListView(
            items: currentCompletionItems,
            onSelect: { [weak self] selection in
                self?.insertCompletion(selection)
                self?.hideCompletionPopover()
            },
            onDismiss: { [weak self] in
                self?.hideCompletionPopover()
            }
        )

        // Setup popover if needed
        if completionPopover == nil {
            completionPopover = NSPopover()
            completionPopover?.behavior = .transient
            completionPopover?.animates = false
        }
        
        // Configure and show popover
        let hostingController = NSHostingController(rootView: contentView)
        completionPopover?.contentViewController = hostingController
        
        let popoverRect = getPopoverRect(in: tv, window: window)
        completionPopover?.show(relativeTo: popoverRect, of: tv, preferredEdge: .maxY)
    }

    func dismissCompletionIfNeeded() -> Bool {
        if completionPopover?.isShown == true {
            hideCompletionPopover()
            return true
        }
        return false
    }

    private func hideCompletionPopover() {
        completionPopover?.close()
        currentCompletionItems.removeAll()
        textView?.window?.makeFirstResponder(textView)
    }
    
    private func insertCompletion(_ item: CompletionItem) {
        guard let tv = textView else { return }
        
        isInsertingCompletion = true

        let caretLocation = tv.selectedRange().location
        let replacementRange = NSRange(location: completionWordStart, length: caretLocation - completionWordStart)
        tv.insertText(item.text, replacementRange: replacementRange)

        currentCompletionItems.removeAll()
        if let newText = tv.text {
            DispatchQueue.main.async {
                self.textChanged(newText: newText)
                    
                // Reset flag after a short delay to allow normal completion again
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isInsertingCompletion = false
                }
            }
            
        } else {
            // Reset flag immediately if no text change
            isInsertingCompletion = false
        }
    }

    func moveCompletionSelection(by offset: Int) {
        guard completionPopover?.isShown == true, !currentCompletionItems.isEmpty else { return }
        
        currentCompletionSelection = (currentCompletionSelection + offset + currentCompletionItems.count) % currentCompletionItems.count
        
        NotificationCenter.default.post(
            name: .completionSelectionChanged,
            object: nil,
            userInfo: ["selectedIndex": currentCompletionSelection]
        )
    }

    func confirmCurrentCompletion() {
        guard completionPopover?.isShown == true,
              currentCompletionItems.indices.contains(currentCompletionSelection) else { return }
        
        let selectedItem = currentCompletionItems[currentCompletionSelection]
        insertCompletion(selectedItem)
        hideCompletionPopover()
    }
    
    // MARK: - Setup input keyboard
    
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        // Se il popup di completamento non è attivo, non gestire l'evento
        guard completionPopover?.isShown == true else { return false }
        
        switch event.keyCode {
        case 125: // Down Arrow
            moveCompletionSelection(by: 1)
            return true
            
        case 126: // Up Arrow
            moveCompletionSelection(by: -1)
            return true
            
        case 36: // Enter/Return
            confirmCurrentCompletion()
            return true
            
        case 53: // Escape
            hideCompletionPopover()
            return true
            
        case 123, 124: // Left/Right Arrow
            if completionPopover?.isShown == true { hideCompletionPopover() }
            
            return false
            
        default:
            return false
        }
    }
    
    private func setupKeyEventHandler(for textView: STTextView) {
        
        if let monitor = keyEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        keyEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let window = textView.window, window.firstResponder == textView else {
                return event
            }
            
            if self.handleKeyEvent(event) {
                return nil
            }
            
            return event
        }
    }
}

extension Notification.Name {
    static let lspDiagnosticsReceived = Notification.Name("LSPDiagnosticsReceived")
    static let completionSelectionChanged = Notification.Name("CompletionSelectionChanged")

}
