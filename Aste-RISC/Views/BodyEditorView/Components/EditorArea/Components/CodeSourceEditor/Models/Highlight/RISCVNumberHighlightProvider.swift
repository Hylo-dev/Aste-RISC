//
//  RISCVNumberHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// MARK: - Number Provider 
class RISCVNumberHighlightProvider: RISCVBaseHighlightProvider {
	private let numberRegex: NSRegularExpression
	
	override init() {
		// Numbers: hex & decimali
		numberRegex = try! NSRegularExpression(pattern: #"\b(?:0x[0-9a-f]+|[-+]?\d+)\b"#, options: [.caseInsensitive])
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
			
			self.numberRegex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				guard let range = match?.range else { return }
				highlights.append(HighlightRange(range: range, capture: .number))
			}
			
			await completion(.success(highlights))
		}
	}
}
