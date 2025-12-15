//
//  Alu.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

struct ALU {
    
    private func alu1Bit(
        a        : Bool,
        b        : Bool,
        less     : Bool,
        carryIn  : Bool,
        operation: AluOperation
        
    ) -> ResultAlu1Bit {
        
        let aInverted = ((operation.rawValue >> 4) & 1) == 1 ? !a : a
        let bInverted = ((operation.rawValue >> 3) & 1) == 1 ? !b : b

        switch operation {
            
        case .and, .not:
            return ResultAlu1Bit(result: aInverted && bInverted, carryOut: false)
            
        case .or:
            return ResultAlu1Bit(result: aInverted || bInverted, carryOut: false)
            
        case .add, .sub:
            let result   = (aInverted != bInverted) != carryIn
            let carryOut = (aInverted && bInverted) || (carryIn && (aInverted != bInverted))
            
            return ResultAlu1Bit(result: result, carryOut: carryOut)
            
        case .slt:
            return ResultAlu1Bit(result: less, carryOut: false)
            
        case .xor:
            return ResultAlu1Bit(result: aInverted != bInverted, carryOut: false)
            
        default:
            return ResultAlu1Bit(result: false, carryOut: false)
            
        }
    }
    
    func getOperation(
        _ operation: UInt8,
          funz3: UInt8,
          funz7: UInt8
        
    ) -> AluOperation {
        
        // Special cases
        switch operation {
			case 0x03, 0x17, 0x6F, 0x23, 0x37: // Load word, AUIPC, JAL, S-Type, LUI
                return .add
				
			case 0x73: // ECALL
				return .skip
				
			case 0x33, 0x13, 0x67: // R-type, I-type ALU, JALR
				break
        
			default:
				return .unknown
        }
        
        // Funct3-based decoding
        switch funz3 {
            
			case 0x0: // ADD/SUB/ADDI/JALR
				if operation == 0x33 && (funz7 & 0x20) != 0 {
					return .sub
				} else {
					return .add
				}
				
			case 0x1: // SLL/SLLI
				return .sll
				
			case 0x2: // SLT/SLTI
				return .slt
				
			case 0x4: // XOR/XORI
				return .xor
				
			case 0x5: // SRL/SRA/SRLI/SRAI
				if (funz7 & 0x20) != 0 {
					return .sra
					
				} else {
					return .srl
					
				}
				
			case 0x6: // OR/ORI
				return .or
				
			case 0x7: // AND/ANDI
				return .and
				
			default:
				return .unknown
        }
    }

    
    func execute(
        a        : Int,
        b        : Int,
        less     : Bool,
        operation: AluOperation
        
    ) -> ResultAlu32Bit {
        var carryIn = ((operation.rawValue >> 3) & 1) == 1
        
        switch operation {
        case .sll:
            let result = Int((a) << (b & 0x1F))
            return ResultAlu32Bit(
				result	: result,
				zero	: result == 0,
				overflow: false
			)
            
        case .srl:
            let result = Int(UInt(bitPattern: a) >> (b & 0x1F))
            return ResultAlu32Bit(
				result	: result,
				zero	: result == 0,
				overflow: false
			)
            
        case .sra:
            let result = a >> (b & 0x1F)
            return ResultAlu32Bit(
				result	: result,
				zero	: result == 0,
				overflow: false
			)
            
        default:
            var result : Int  = 0
            
            var carryInOverflowControl : Bool = false
            var carryOutOverflowContral: Bool = false
            
            for i in 0 ..< 32 {
                let bitA = ((a >> i) & 1) == 1
                let bitB = ((b >> i) & 1) == 1
                let lessInput = i == 31 ? less : false
                
                let res = alu1Bit(a: bitA, b: bitB, less: lessInput, carryIn: carryIn, operation: operation)
                
                if res.result { result |= (1 << i) }
                carryIn = res.carryOut
                
                if i == 30 { carryInOverflowControl = carryIn }
                if i == 31 { carryOutOverflowContral = res.carryOut }
            }
            
            let zero = result == 0
            let overflow = carryInOverflowControl != carryOutOverflowContral
            
            return ResultAlu32Bit(result: result, zero: zero, overflow: overflow)
        }
                
    }
    
}
