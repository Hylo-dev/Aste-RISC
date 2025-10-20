//
//  CompletionItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/09/25.
//

import Foundation
import SwiftUI
/// A code completion item that represents a suggestion from the Language Server Protocol (LSP).
///
/// This struct encapsulates all the information needed to display and insert code completions
/// in a code editor, including the display text, insertion text, type information, and documentation.
///
/// - Note: The struct automatically processes LSP completion data to provide clean text and
///   appropriate insertion behavior based on the completion type.
struct CompletionItem: Identifiable, Equatable {
    /// Unique identifier for the completion item
    let id = UUID()
    
    /// The verbose text displayed to the user in the completion list
    let text: String
    
    /// The plain text that will be inserted when this completion is selected
    let insertText: String
    
    /// The type of completion item (function, variable, class, etc.)
    let kind: CompletionItemKind
    
    /// Optional return type or additional type information
    let detail: String?
    
    /// Optional documentation string explaining the completion item
    let documentation: String?
    
    /// Enumeration representing different types of code completion items.
    ///
    /// This enum corresponds to the LSP CompletionItemKind specification and provides
    /// visual representation through icons and colors for each type.
    enum CompletionItemKind: Int, CaseIterable {
        case text = 1
        case method = 2
        case function = 3
        case constructor = 4
        case field = 5
        case variable = 6
        case `class` = 7
        case interface = 8
        case module = 9
        case property = 10
        case unit = 11
        case value = 12
        case `enum` = 13
        case keyword = 14
        case snippet = 15
        case color = 16
        case file = 17
        case reference = 18
        case folder = 19
        case enumMember = 20
        case constant = 21
        case `struct` = 22
        case event = 23
        case `operator` = 24
        case typeParameter = 25
        
        /// Returns a short string icon representation for the completion kind
        var icon: String {
            switch self {
            case .function, .method: return "f(x)"
            case .variable: return "var"
            case .class: return "C"
            case .struct: return "S"
            case .interface: return "I"
            case .enum, .enumMember: return "E"
            case .keyword: return "K"
            case .constant: return "const"
            case .property: return "P"
            case .typeParameter: return "T"
            default: return "•"
            }
        }
        
        /// Returns the appropriate color for this completion kind
        var color: Color {
            switch self {
            case .function, .method, .constructor: return .blue
            case .variable, .property, .field: return .green
            case .class, .struct, .interface: return .purple
            case .keyword: return .orange
            case .constant: return .red
            default: return .gray
            }
        }
    }
    
    /// Creates a CompletionItem from an LSP completion response.
    ///
    /// This initializer processes the raw LSP data, cleaning up the label text and
    /// automatically adding parentheses for function completions.
    ///
    /// - Parameter lspCompletion: The raw LSP completion item data
//    init(from lspCompletion: LSPCompletionItem) {
//        self.text = lspCompletion.label.replacingOccurrences(of: "•", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//        self.kind = CompletionItemKind(rawValue: lspCompletion.kind ?? 1) ?? .text
//        self.insertText = "\(lspCompletion.insertText ?? "")\(self.kind == .function ? "()" : "")"
//        self.detail = lspCompletion.detail
//        self.documentation = lspCompletion.documentation
//    }
}
