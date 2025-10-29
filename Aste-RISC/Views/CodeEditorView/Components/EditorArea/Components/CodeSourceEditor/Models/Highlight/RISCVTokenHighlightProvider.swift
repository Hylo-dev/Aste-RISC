//
//  RISCVNumberHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import Foundation
import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// MARK: - Number Provider
class RISCVTokenHighlightProvider: RISCVBaseHighlightProvider {
	private let registerRegex: NSRegularExpression
	
	override init() {
		registerRegex = try! NSRegularExpression(pattern: #"\b(?:x[0-9]{1,2}|zero|ra|sp|gp|tp|[tsa][0-7]|s(?:10|11))\b"#, options: [.caseInsensitive])
		
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
			
			self.registerRegex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				guard let range = match?.range else { return }
				highlights.append(HighlightRange(range: range, capture: .variable))
			}
			
			await completion(.success(highlights))
		}
	}
}
