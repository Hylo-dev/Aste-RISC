//
//  RISCVDirectiveHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import Foundation
import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// MARK: - Directive Provider
class RISCVKeywordHighlightProvider: RISCVBaseHighlightProvider {
	private let directiveRegex: NSRegularExpression
	private let instructionRegex: NSRegularExpression
	
	override init() {
		// Direttive: .text, .data, etc
		directiveRegex = try! NSRegularExpression(pattern: #"^\s*\.[a-zA-Z_]\w*\b"#, options: [.anchorsMatchLines])
		
		// Istruzioni: add, lw, etc
		instructionRegex = try! NSRegularExpression(pattern: #"(?:^|\s)([a-z][a-z.]*)\s"#, options: [.caseInsensitive])
		
		super.init()
	}
	
	override func queryHighlightsFor(textView: TextView, range: NSRange, completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void) {
		guard let text = textView.textStorage?.string else {
			completion(.success([]))
			return
		}
		
		let searchRange = NSIntersectionRange(NSMakeRange(0, text.count), range)
		guard searchRange.length > 0 else {
			completion(.success([]))
			return
		}
		
		Task.detached(priority: .userInitiated) {
			var highlights: [HighlightRange] = []
			
			self.directiveRegex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				guard let range = match?.range else { return }
				highlights.append(HighlightRange(range: range, capture: .keyword))
			}
			
			self.instructionRegex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				guard let range = match?.range(at: 1) else { return }
				highlights.append(HighlightRange(range: range, capture: .keyword))
			}
			
			await completion(.success(highlights))
		}
	}
}
