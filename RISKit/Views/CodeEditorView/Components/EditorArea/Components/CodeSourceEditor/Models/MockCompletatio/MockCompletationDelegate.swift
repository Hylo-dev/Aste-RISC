//
//  MockCompletationDelegate.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/10/25.
//

import SwiftUI
import CodeEditSourceEditor
import CodeEditTextView
internal import Combine

private let riscvKeywords: [RiscvKeyword] = riscvInstructions + riscvRegisters + riscvDirectives

// MARK: - Delegate
class MockCompletionDelegate: CodeSuggestionDelegate, ObservableObject {
	private var lastAppliedSuggestion: String?
	var lastPosition: CursorPosition?

	class Suggestion: CodeSuggestionEntry {
		var label: String
		var detail: String?
		var documentation: String?
		var pathComponents: [String]?
		var targetPosition: CursorPosition? = nil
		var sourcePreview: String?
		var image: Image
		var imageColor: Color
		var deprecated: Bool = false

		init(
			text: String,
			detail: String?,
			documentation: String,
			category: RiscvCategory
		) {
			self.label = text
			self.detail = detail
			self.documentation = documentation
			self.pathComponents = [category.rawValue]

			switch category {
				case .instruction:
					self.image = Image(systemName: "dot.square.fill")
					self.imageColor = .blue
						
				case .directive:
					self.image = Image(systemName: "dot.square.fill")
					self.imageColor = .purple
						
				case .register:
					self.image = Image(systemName: "dot.square.fill")
					self.imageColor = .green
					
			}
		}
	}

	// MARK: - Genera suggerimenti filtrati
	private func riscvSuggestions(for prefix: String) -> [Suggestion] {
		let lowerPrefix = prefix.lowercased()
		
		let matches = riscvKeywords.filter { $0.label.lowercased().hasPrefix(lowerPrefix) }
		
		return matches.map { key in
			let detail: String?
			let documentation: String
			
			switch key.category {
				case .instruction:
					detail = key.instructionDetail?.format
					documentation = key.documentation
					
				case .directive:
					detail = key.directiveDetail?.syntax
					documentation = key.documentation
					
				case .register:
					detail = key.documentation
					documentation = key.registerDetail?.usage ?? ""
			}
			
			return Suggestion(
				text: key.label,
				detail: detail,
				documentation: documentation,
				category: key.category
			)
		}
	}


	// MARK: - Completamento iniziale (invocato async)
	func completionSuggestionsRequested(
		textView: TextViewController,
		cursorPosition: CursorPosition
		
	) async -> (windowPosition: CursorPosition, items: [CodeSuggestionEntry])? {
		try? await Task.sleep(for: .milliseconds(80))
		lastPosition = cursorPosition

		let text = textView.textView.string
		let prefix = extractWordPrefix(from: text, at: cursorPosition.range.location)
		let suggestions = riscvSuggestions(for: prefix)
		
		return (cursorPosition, suggestions)
	}

	// MARK: - Aggiornamento in tempo reale
	func completionOnCursorMove(
		textView: TextViewController,
		cursorPosition: CursorPosition
		
	) -> [CodeSuggestionEntry]? {
		guard let last = lastPosition,
			  abs(cursorPosition.range.location - last.range.location) <= 1 else {
			lastPosition = cursorPosition
			
			return nil
		}

		lastPosition = cursorPosition
		let text = textView.textView.string
		let prefix = extractWordPrefix(from: text, at: cursorPosition.range.location)
		
		if let lastApplied = lastAppliedSuggestion, lastApplied == prefix {
			return nil
		}
		
		return riscvSuggestions(for: prefix)
	}

	// MARK: - Applicazione completamento scelto
	func completionWindowApplyCompletion(
		item: CodeSuggestionEntry,
		textView: TextViewController,
		cursorPosition: CursorPosition?
		
	) {
		guard let suggestion = item as? Suggestion,
			  let cursorPosition = cursorPosition else { return }

		let textStorage = textView.textView.textStorage
		let fullText = textStorage?.string ?? ""
		let cursorIndex = cursorPosition.range.location

		let start = findWordStart(in: fullText, before: cursorIndex)
		let range = NSRange(location: start, length: cursorIndex - start)

		textView.textView.undoManager?.beginUndoGrouping()
		textView.textView.selectionManager.setSelectedRange(range)
		textView.textView.insertText(suggestion.label)
		textView.textView.undoManager?.endUndoGrouping()
		
		lastAppliedSuggestion = suggestion.label
	}

	// MARK: - Helpers
	private func extractWordPrefix(from text: String, at index: Int) -> String {
		guard index > 0 else { return "" }
		let startIndex = text.index(text.startIndex, offsetBy: max(0, index - 32))
		let sub = text[startIndex..<text.index(text.startIndex, offsetBy: index)]
		let comps = sub.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "." })
		return comps.last.map(String.init) ?? ""
	}

	private func findWordStart(in text: String, before index: Int) -> Int {
		guard index > 0 else { return 0 }
		let chars = Array(text)
		var i = index - 1
		while i > 0 && (chars[i].isLetter || chars[i].isNumber || chars[i] == ".") {
			i -= 1
		}
		return (chars[i].isLetter || chars[i].isNumber || chars[i] == ".") ? i : i + 1
	}
}
