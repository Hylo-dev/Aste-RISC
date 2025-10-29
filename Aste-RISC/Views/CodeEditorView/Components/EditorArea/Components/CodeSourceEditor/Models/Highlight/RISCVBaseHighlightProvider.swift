//
//  RISCVBaseHighlightProvider.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 29/10/25.
//

import CodeEditTextView
@preconcurrency import CodeEditSourceEditor
import CodeEditLanguages
import SwiftUI

// Defines a base class for providing syntax highlighting, conforming to the HighlightProviding protocol.
class RISCVBaseHighlightProvider: HighlightProviding {
	// Stores the timestamp of the last edit to help with debouncing.
	private var lastEditTime: Date = .distantPast
	// The minimum time interval between edits to trigger a re-highlighting pass.
	private let minEditInterval: TimeInterval = 0.1
	
	// A setup method required by the protocol, currently not implemented.
	func setUp(textView: TextView, codeLanguage: CodeLanguage) {}
	
	/**
	 * Called when the text in the text view is edited.
	 * It determines which lines have been affected by the change.
	 *
	 * - Parameters:
	 * - textView: The text view where the edit occurred.
	 * - range: The range of the new text.
	 * - delta: The change in length of the text.
	 * - completion: A closure to call with the set of indices that need re-highlighting.
	 */
	func applyEdit(textView: TextView, range: NSRange, delta: Int, completion: @escaping @MainActor (Result<IndexSet, any Error>) -> Void) {
		// Ensure the text storage is available.
		guard let storage = textView.textStorage else {
			completion(.success(IndexSet()))
			return
		}
		
		// Get the current time.
		let now = Date()
		// Calculate the time elapsed since the last edit.
		let timeSinceLastEdit = now.timeIntervalSince(lastEditTime)
		
		// Debounce: If the edit happened too quickly and was just a cursor movement (no text changed), do nothing.
		if timeSinceLastEdit < minEditInterval && delta == 0 && range.length == 0 {
			completion(.success(IndexSet()))
			return
		}
		
		// Update the last edit time to now.
		lastEditTime = now
		
		// Get the text content as an NSString for efficient range calculations.
		let text = storage.string as NSString
		let newLength = storage.length
		
		// Ensure the text is not empty and the edited range is valid.
		guard newLength > 0, range.location < newLength else {
			completion(.success(IndexSet()))
			return
		}
		
		// Determine the full line range that contains the edited range.
		let lineRange = text.lineRange(for: range)
		// Return the character range of the affected lines to the system for re-highlighting.
		completion(.success(IndexSet(integersIn: lineRange.location ..< NSMaxRange(lineRange))))
	}
	
	/**
	 * This method is responsible for providing the actual highlight ranges (e.g., tokens and their colors).
	 * In this base class, it does nothing and returns an empty array. Subclasses should override this.
	 *
	 * - Parameters:
	 * - textView: The text view requesting highlights.
	 * - range: The character range for which to provide highlights.
	 * - completion: A closure to call with the calculated highlight ranges.
	 */
	func queryHighlightsFor(textView: TextView, range: NSRange, completion: @escaping @MainActor (Result<[HighlightRange], any Error>) -> Void) {
		// Complete with an empty array of highlights, as this is a base implementation.
		completion(.success([]))
	}
}
