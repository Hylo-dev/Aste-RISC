//
//  RISCVLabelHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import Foundation
import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// MARK: - Label Provider
class RISCVLabelHighlightProvider: RISCVBaseHighlightProvider {
	private let regex: NSRegularExpression
	
	override init() {
		regex = try! NSRegularExpression(pattern: #"^\s*[a-zA-Z_]\w*(?=:)"#, options: [.anchorsMatchLines])
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
			
			self.regex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				guard let range = match?.range else { return }
				highlights.append(HighlightRange(range: range, capture: .function))
			}
			
			await completion(.success(highlights))
		}
	}
}
