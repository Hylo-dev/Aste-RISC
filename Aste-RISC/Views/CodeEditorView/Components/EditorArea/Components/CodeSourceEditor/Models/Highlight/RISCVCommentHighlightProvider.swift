//
//  RISCVCommentHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import Foundation
import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// A concrete highlight provider that finds and highlights single-line comments in RISC-V assembly.
class RISCVCommentHighlightProvider: RISCVBaseHighlightProvider {
	// The regular expression used to find comments, which start with '#' and go to the end of the line.
	private let regex: NSRegularExpression
	
	// Initializes the provider by compiling the regular expression.
	override init() {
		regex = try! NSRegularExpression(pattern: #"#.*$"#, options: [.anchorsMatchLines])
		super.init()
	}
	
	/**
	 * Overrides the base method to perform the search for comment highlights.
	 * This method runs asynchronously to avoid blocking the UI.
	 *
	 * - Parameters:
	 * - textView: The text view containing the code.
	 * - range: The character range that needs to be highlighted.
	 * - completion: The callback to return the found highlight ranges.
	 */
	override func queryHighlightsFor(textView: TextView, range: NSRange, completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void) {
		// Safely get the full text from the text view's storage.
		guard let text = textView.textStorage?.string else {
			completion(.success([]))
			return
		}
		
		// Calculate the intersection of the requested range and the total text range to ensure we search within valid bounds.
		let searchRange = NSIntersectionRange(NSMakeRange(0, text.count), range)
		// If the resulting search range is empty, there's nothing to do.
		guard searchRange.length > 0 else {
			completion(.success([]))
			return
		}
		
		// Perform the potentially slow regex matching on a background thread to keep the UI responsive.
		Task.detached(priority: .userInitiated) {
			var highlights: [HighlightRange] = []
			
			// Enumerate all matches of the regex within the specified search range.
			self.regex.enumerateMatches(in: text, options: [], range: searchRange) { match, _, _ in
				// For each match, safely unwrap its range.
				guard let range = match?.range else { return }
				// Create a HighlightRange object for the comment and add it to the results array.
				highlights.append(HighlightRange(range: range, capture: .comment))
			}
			
			// On completion, switch back to the main thread and pass the array of found highlights.
			await completion(.success(highlights))
		}
		
	}
}
