//
//  Cpu.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import Foundation
internal import Combine

class CPU: ObservableObject {
    @Published var programCounter: UInt
    
    var registers             : [Int]

    private let resetFlag     : Int
    private let alu           : ALU
    
    let ram                   : RAM
    
    init(ram: RAM) {
        self.programCounter = 0
        self.resetFlag      = -1
        self.registers      = [Int](repeating: 0, count: 32)
        self.alu            = ALU()
        self.ram            = ram
    }
    
    func runStep(
        optionsSource: options_t,
        mainMemory   : RAM
        
    ) -> Bool {
        if programCounter >= optionsSource.text_vaddr && programCounter < Int(optionsSource.text_vaddr) + optionsSource.text_size {
            
            return execute(optionsSource: optionsSource, mainMemory: ram)
        }
        
        return false
    }
    
    private func execute(
        optionsSource: options_t,
        mainMemory   : RAM
        
    ) -> Bool {
        var nextProgramCounter = programCounter + 4
        
        let rawInstruction = fetch(optionsSource: optionsSource, mainMemory: mainMemory)
                
        if rawInstruction == -1 {
            return false
        }
        
        let decodedInstruction = decode(Int(rawInstruction))
        
        let controlUnitState   = getControlSignals(decodedInstruction.operationCode)
        
        let aluOperation       = alu.getOperation(
            controlUnitState.operation,
            funz3: decodedInstruction.funz3,
            funz7: decodedInstruction.funz7
        )
        
        if aluOperation == .unknown {
            print("Invalid operation")
            return false
        }
        
        var firstOperand  = 0
        var secondOperand = 0
        var resultAlu: ResultAlu32Bit = ResultAlu32Bit(result: 0, zero: false, overflow: false)
        
        if aluOperation != .skip {
            
            firstOperand = controlUnitState.operation == 0x17 ? Int(programCounter) : getValueRegister(register: Int(decodedInstruction.registerSource1))
            
            secondOperand = controlUnitState.alu_src ? decodedInstruction.immediate : getValueRegister(register: Int(decodedInstruction.registerSource2))
                        
            resultAlu = alu.execute(a: firstOperand, b: secondOperand, less: false, operation: aluOperation)
        }
        
        // ADD FUNC TO SLEEP WHILE
        
        if (decodedInstruction.operationCode == 0x67 && decodedInstruction.funz3 == 0) ||
            decodedInstruction.operationCode == 0x6F {
            
            if controlUnitState.reg_write {
                if !writeRegister(value: Int(nextProgramCounter), destination: Int(decodedInstruction.registerDestination)) {
                    return false
                }
            }
            
            nextProgramCounter = UInt(decodedInstruction.operationCode == 0x6F ?
                                      Int(programCounter) + secondOperand & ~1:
                                      firstOperand + secondOperand & ~1)
            
        } else if controlUnitState.reg_write && aluOperation == .skip {
            if !writeRegister(value: decodedInstruction.immediate, destination: Int(decodedInstruction.registerDestination)) {
                return false
            }
            
        } else if controlUnitState.mem_read && controlUnitState.alu_src {
            let valueRamRead = read_ram32bit(ram, UInt32(resultAlu.result))
            
            if valueRamRead == -1 {
                print("Ram value not read")
                return false
            }
            
            if !writeRegister(value: Int(valueRamRead), destination: Int(decodedInstruction.registerDestination)) {
                return false
            }
            
        } else if controlUnitState.reg_write {
            if !writeRegister(value: resultAlu.result, destination: Int(decodedInstruction.registerDestination)) {
                return false
            }
        }
        
        programCounter = nextProgramCounter
        
//        for (i, reg) in registers.enumerated() {
//            print("x\(i) = 0x\(String(reg, radix: 16, uppercase: true))")
//        }
//        print("----------")
        return true
    }
    
    private func fetch(
        optionsSource: options_t,
        mainMemory   : RAM
        
    ) -> Int32 {
        
        if programCounter < optionsSource.text_vaddr || programCounter >= Int(optionsSource.text_vaddr) + optionsSource.text_size {
            print("Invalid program counter, outside the text section");
            return -1;
            
        }

        if ((programCounter % 4) != 0) {
            print("Program counter must be aligned to 4 bytes for RISC-V instructions");
            return -1;
            
        }

        return read_ram32bit(mainMemory, UInt32(programCounter));
    }
    
    private func decode(_ instruction: Int) -> DecodedInstruction {
        var decoded = DecodedInstruction(
            operationCode      : UInt8(extractBits(instruction, start: 0, end: 6)),
            registerSource1    : UInt8(extractBits(instruction, start: 15, end: 19)),
            registerSource2    : UInt8(extractBits(instruction, start: 20, end: 24)),
            registerDestination: UInt8(extractBits(instruction, start: 7, end: 11)),
            immediate          : 0,
            funz3              : UInt8(extractBits(instruction, start: 12, end: 14)),
            funz7              : UInt8(extractBits(instruction, start: 30, end: 30))
        )
        
        switch decoded.operationCode {
            
        case 0x67, 0x13, 0x03:
            let extractedBits = extractBits(instruction, start: 20, end: 31)
            decoded.immediate = signExtend(value: extractedBits, bits: 12)
                        
            // S-Type instruction
        case 0x23:
            let immediateAt11To5   = extractBits(instruction, start: 25, end: 31)
            let immediateAt4To0    = extractBits(instruction, start: 7, end: 11)
            let calculateImmediate = immediateAt11To5 << 5 | immediateAt4To0
            
            decoded.immediate = signExtend(value: calculateImmediate, bits: 12)
            
            // J-Type instruction
        case 0x6F:
            let immediateAt20      = extractBits(instruction, start: 31, end: 31)
            let immediateAt19To12  = extractBits(instruction, start: 12, end: 19)
            let immediateAt11      = extractBits(instruction, start: 20, end: 20)
            let immediateAt10To1   = extractBits(instruction, start: 21, end: 30)
            let calculateImmediate = immediateAt20 << 20 | immediateAt19To12 << 12 | immediateAt11 << 11 | immediateAt10To1 << 1
            
            decoded.immediate = signExtend(value: calculateImmediate, bits: 21)
            
        case 0x37, 0x17:
            decoded.immediate = Int(extractBits(instruction, start: 12, end: 31) << 12)
            
        default:
            decoded.immediate = 0
        }
        
        return decoded
    }
    
    private func writeRegister(value: Int, destination registerNumber: Int) -> Bool {
        if registerNumber <= 0 || registerNumber >= 32 { return false }
        
        registers[registerNumber] = value
        return true
    }
    
    private func getValueRegister(register indexRegister: Int) -> Int {
        if indexRegister < 0 || indexRegister >= 32 { return -1 }
        
        return registers[indexRegister]
    }
    
    private func extractBits(_ instruction: Int, start: Int, end: Int) -> Int {
        return instruction >> start & ((1 << (end - start + 1)) - 1);
    }
    
    private func signExtend(value: Int, bits: Int) -> Int {
        let shift = 32 - bits
        return (value << shift) >> shift
    }
    
    func loadEntryPoint(value: UInt) {
        self.programCounter = value
    }
}
