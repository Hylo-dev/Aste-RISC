//
//  String+Highlight.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 05/11/25.
//

import Foundation
import SwiftUI

extension String {

	func highlightingMatches(of filter: String) -> AttributedString {
		guard !filter.isEmpty else {
			return AttributedString(self)
		}
		
		var attributedString = AttributedString(self)
		
		let lowercasedSelf = self.lowercased()
		let lowercasedFilter = filter.lowercased()
		
		var searchRange = lowercasedSelf.startIndex..<lowercasedSelf.endIndex
		
		while let range = lowercasedSelf.range(of: lowercasedFilter, range: searchRange) {
			if let attrRange = Range(range, in: attributedString) {
				attributedString[attrRange].foregroundColor = .primary
				attributedString[attrRange].font = .body.bold()
			}
			
			searchRange = range.upperBound..<lowercasedSelf.endIndex
		}
		
		return attributedString
	}
}
