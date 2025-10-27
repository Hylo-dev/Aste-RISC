//
//  MemorySection.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 27/10/25.
//

import Foundation
import SwiftUI

struct MemorySection: Identifiable {
	let id 			: UUID = UUID()
	let name		: String
	let startAddress: UInt32
	let size		: UInt32
	let color		: Color
	let type		: SectionType
	
	enum SectionType {
		case text, data, stack, heap, unused
	}
	
	var endAddress: UInt32 {
		startAddress + size
	}
}
