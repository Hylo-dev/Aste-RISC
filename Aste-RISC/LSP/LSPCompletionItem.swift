//
//  LSPCompletionItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 04/09/25.
//

// Represents a single completion item returned by an LSP server (e.g., clangd).
// It mirrors the LSP CompletionItem fields we use and handles decoding variations.
struct LSPCompletionItem: Codable {
    // Text shown in the completion list
    let label: String
    // LSP kind (numbered enum per spec)
    let kind: Int?
    // Extra detail text (e.g., type)
    let detail: String?
    // Optional documentation (may be plain string or markup object)
    let documentation: String?
    // Optional explicit insertion text
    let insertText: String?
    
    // Optional text edit object (server may provide exact text to insert)
    struct TextEdit: Codable {
        let newText: String
    }
    let textEdit: TextEdit?

    // Coding keys for decoding
    enum CodingKeys: String, CodingKey {
        case label, kind, detail, documentation, insertText, textEdit
        
    }

    // Custom decoder to support documentation as either:
    // - String
    // - { "value": "..."} or {"contents": "..."} object
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decode(String.self, forKey: .label)
        self.kind = try container.decodeIfPresent(Int.self, forKey: .kind)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
        self.insertText = try container.decodeIfPresent(String.self, forKey: .insertText)
        self.textEdit = try container.decodeIfPresent(TextEdit.self, forKey: .textEdit)

        if let docStr = try? container.decodeIfPresent(String.self, forKey: .documentation) {
            self.documentation = docStr
            
        } else if let docObj = try? container.decodeIfPresent([String: String].self, forKey: .documentation) {
            // Try common LSP markup keys
            self.documentation = docObj["value"] ?? docObj["contents"] ?? nil
            
        } else {
            self.documentation = nil
            
        }
    }

    // Returns the best text to insert: prefer textEdit.newText, else insertText.
    var bestInsertText: String? {
        if let te = textEdit?.newText { return te }
        return insertText
        
    }
}
