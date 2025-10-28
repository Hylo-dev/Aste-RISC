//
//  LSPDiagnostic.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//
import Foundation
import AppKit

// Represents a single diagnostic (error/warning/info/hint) from an LSP server.
struct LSPDiagnostic {
    // Severity levels mapped from LSP numeric codes
    enum Severity {
        case error, warning, info, hint
    }

    // Range in the document (UTF-16 based, as NSRange)
    let range: NSRange
    // Human-readable message
    let message: String
    // Diagnostic severity
    let severity: Severity

    // Initialize from a raw LSP dictionary and the full document text.
    // Safely parses message, severity, and range.
    init?(from dict: [String: Any], inText text: String) {
        // Message is required
        guard let message = dict["message"] as? String else { return nil }
        self.message = message

        // Map LSP numeric severity to local enum (default to .info)
        if let rawSeverity = dict["severity"] as? Int {
            switch rawSeverity {
                case 1: self.severity = .error
                case 2: self.severity = .warning
                case 3: self.severity = .info
                case 4: self.severity = .hint
                default: self.severity = .info
            }
        } else {
            self.severity = .info
        }

        // Parse LSP range: { start: {line, character}, end: {line, character} }
        if let rangeDict = dict["range"] as? [String: Any],
           let start = rangeDict["start"] as? [String: Any],
           let end = rangeDict["end"] as? [String: Any],
           let startLine = start["line"] as? Int,
           let startChar = start["character"] as? Int,
           let endLine = end["line"] as? Int,
           let endChar = end["character"] as? Int {

            // Convert LSP positions to NSRange using UTF-16 safe helpers
            let nsRange = text.nsRangeFrom(lspStartLine: startLine,
                                           lspStartCharacter: startChar,
                                           lspEndLine: endLine,
                                           lspEndCharacter: endChar)
            self.range = nsRange
            return
        }

        // Fallback to empty range if range data is missing/malformed
        self.range = NSRange(location: 0, length: 0)
    }
}

// MARK: - String helpers (UTF-16 safe)
// These helpers convert LSP line/character positions to NSRange safely using UTF-16.
extension String {
    // Returns the UTF-16 offset of the first character of the given line (0-based).
    // Walks the string line-by-line to find the starting offset.
    func utf16OffsetOfLineStart(_ line: Int) -> Int {
        if line <= 0 { return 0 }
        let ns = self as NSString
        var idx = 0
        var currentLine = 0

        while currentLine < line && idx < ns.length {
            let searchRange = NSRange(location: idx, length: ns.length - idx)
            let range = ns.range(of: "\n", options: [], range: searchRange)
            if range.location == NSNotFound {
                idx = ns.length
                break
            } else {
                idx = range.location + 1
                currentLine += 1
            }
        }

        return idx
    }

    // Converts LSP start/end (line, character) into an NSRange in this string.
    // Clamps values to valid UTF-16 bounds to avoid crashes.
    func nsRangeFrom(lspStartLine: Int, lspStartCharacter: Int, lspEndLine: Int, lspEndCharacter: Int) -> NSRange {
        let ns = self as NSString
        let startLineOffset = utf16OffsetOfLineStart(lspStartLine)
        let start = min(ns.length, startLineOffset + lspStartCharacter)

        let endLineOffset = utf16OffsetOfLineStart(lspEndLine)
        let end = min(ns.length, endLineOffset + lspEndCharacter)

        let length = max(0, end - start)
        return NSRange(location: start, length: length)
    }
}
