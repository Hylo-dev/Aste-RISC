//
//  StackFrame.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/10/25.
//

import Foundation
import SwiftUI

struct StackFrame: Identifiable, Equatable {
	let id: UUID = UUID()
	let address: UInt32
	let value: Int32
	let color: Color
	let label: String

	// meta
	let isPointer: Bool        // sembra un puntatore (pointing into .text)
	let isNonZero: Bool        // != 0 e != -1
	let isError: Bool          // read error (-1)
	let isFrameBoundary: Bool  // euristica: possibile boundary (es. return addr)
	let offsetFromSP: Int      // word index (0 = top)
}
