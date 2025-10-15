//
//  AluOperation.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

enum AluOperation: UInt8 {
    case and = 0
    case not = 24
    case or  = 1
    case add = 2
    case sub = 10
    case slt = 3
    case sll = 4
    case srl = 5
    case sra = 6
    case xor = 7
    
    case skip = 14
    case unknown = 15
}
