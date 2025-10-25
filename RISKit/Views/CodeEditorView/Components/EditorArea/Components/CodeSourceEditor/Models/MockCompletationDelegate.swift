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

private let riscvKeywords: [String] = [
	// Istruzioni base RV32I
	"ADD", "ADDI", "SUB", "LUI", "AUIPC",
	"JAL", "JALR", "BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU",
	"LB", "LH", "LW", "LBU", "LHU",
	"SB", "SH", "SW",
	"SLL", "SRL", "SRA", "SLLI", "SRLI", "SRAI",
	"AND", "OR", "XOR", "ANDI", "ORI", "XORI",
	"SLT", "SLTI", "SLTU", "SLTIU",

	// Direttive tipiche dell’assembler
	".text", ".data", ".bss", ".globl", ".align", ".word", ".byte", ".half", ".asciz",

	// Registri
	"x0", "x1", "x2", "x3", "x4", "x5", "x6", "x7",
	"x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15",
	"x16", "x17", "x18", "x19", "x20", "x21", "x22", "x23",
	"x24", "x25", "x26", "x27", "x28", "x29", "x30", "x31",

	// Alias per leggibilità
	"zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
	"s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11",
	"t3", "t4", "t5", "t6"
]

class MockCompletionDelegate: CodeSuggestionDelegate, ObservableObject {
	var lastPosition: CursorPosition?

	class Suggestion: CodeSuggestionEntry {
		var label: String
		var detail: String?
		var documentation: String?
		var pathComponents: [String]?
		var targetPosition: CursorPosition? = CursorPosition(line: 10, column: 20)
		var sourcePreview: String?
		var image: Image = Image(systemName: "dot.square.fill")
		var imageColor: Color = .gray
		var deprecated: Bool = false

		init(
			text: String,
			detail: String?,
			sourcePreview: String?,
			documentation: String,
			pathComponents: [String]?
		) {
			self.label 			= text
			self.detail		    = detail
			self.sourcePreview  = sourcePreview
			self.documentation  = documentation
			self.pathComponents = pathComponents
		}
	}

	private func riscvSuggestions(for prefix: String) -> [Suggestion] {
		let matches = riscvKeywords.filter { $0.lowercased().hasPrefix(prefix.lowercased()) }
		
		return matches.map {
			Suggestion(
				text: $0,
				detail: "rd, rs1, imm",
				sourcePreview: "TEST",
				documentation: "DOC",
				pathComponents: ["RISC-V"]
			)
		}
	}

	var moveCount = 0

	func completionSuggestionsRequested(
		textView: TextViewController,
		cursorPosition: CursorPosition
		
	) async -> (windowPosition: CursorPosition, items: [CodeSuggestionEntry])? {
		try? await Task.sleep(for: .milliseconds(100))
		lastPosition = cursorPosition

		let currentText = textView.textView.string
		let cursorIndex = cursorPosition.range.location
		let prefix = extractWordPrefix(from: currentText, at: cursorIndex)

		let suggestions = riscvSuggestions(for: prefix)
		return (cursorPosition, suggestions)
	}
	
	private func extractWordPrefix(from text: String, at index: Int) -> String {
		guard index > 0 else { return "" }
		let startIndex = text.index(text.startIndex, offsetBy: max(0, index - 32))
		let sub = text[startIndex..<text.index(text.startIndex, offsetBy: index)]
		let components = sub.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "." })
		
		return components.last.map(String.init) ?? ""
	}

	func completionOnCursorMove(
		textView: TextViewController,
		cursorPosition: CursorPosition
	) -> [CodeSuggestionEntry]? {
		return nil
	}

	func completionWindowApplyCompletion(
		item: CodeSuggestionEntry,
		textView: TextViewController,
		cursorPosition: CursorPosition?
	) {
		guard let suggestion = item as? Suggestion,
			  let cursorPosition = cursorPosition
		else { return }

		let textStorage = textView.textView.textStorage
		let cursorIndex = cursorPosition.range.location
		let fullText = textStorage?.string

		// Trova l’inizio della parola corrente
		let prefixStartIndex = findWordStart(in: fullText ?? "", before: cursorIndex)
		let prefixRange = NSRange(location: prefixStartIndex, length: cursorIndex - prefixStartIndex)

		// Esegui la sostituzione vera e propria
		textView.textView.undoManager?.beginUndoGrouping()
		textView.textView.selectionManager.setSelectedRange(prefixRange)
		textView.textView.insertText(suggestion.label)
		textView.textView.undoManager?.endUndoGrouping()
	}

	private func findWordStart(in text: String, before index: Int) -> Int {
		guard index > 0 else { return 0 }
		let characters = Array(text)
		var i = index - 1
		while i > 0 && (characters[i].isLetter || characters[i].isNumber || characters[i] == ".") {
			i -= 1
		}
		
		return (characters[i].isLetter || characters[i].isNumber || characters[i] == ".") ? i : i + 1
	}

}
