//
//  MapInstructions.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 20/10/25.
//

struct MapInstructions: Equatable {
    var indexInstruction   : UInt32? = nil
    var indexesInstructions: [Int]   = []
	
	func getIndexCurrentProgramCounter() -> Int {
		return indexesInstructions[Int(indexInstruction ?? 0)]
	}
	
	func getIndex(_ index: Int) -> Int? {
		guard index >= 0 && index < indexesInstructions.count else { return nil }
		
		return indexesInstructions[index]
	}
}
