//
//  Cpu.swift
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/10/25.
//

import SwiftUI
import Foundation
internal import Combine

class CPU: ObservableObject {
	
	/// Program counter, this contain adrress for current
	/// instruction
	@Published
	var programCounter: UInt32
	
	/// Contains all register CPU, default value is zero
	@Published
	var registers: [Int]
	
	/// Manage the stack frame stores in memory
	@Published
	var stackStores: [UInt32: Int] = [:]
		
	/// Struct for manage the aritmethic operations bit a bit
	private let alu: ALU
	
	/// All frame pointer address
	private var framePointers: [UInt32] = []
	
	/// Cronology for old stacks frames
	var historyStack: [StateChange] = []
	
	/// Flag for reset all values on CPU
	var resetFlag: Bool
	
	/// Main Memory structure,
	/// this is nil because this is init late.
	var ram: RAM? = nil
	
	init() {
		self.programCounter = 0
		self.resetFlag 		= false
		self.registers	    = [Int](repeating: 0, count: 32)
		self.alu 			= ALU()
	}
	
	/// Destroy struct, free RAM structure and set self nil
	deinit {
		if destroy_ram(self.ram) { self.ram = nil }
	}
	
	/// Reset all CPU status
	func resetCpu() {
		self.stackStores 	= [:]
		self.registers 		= [Int](repeating: 0, count: 32)
		self.programCounter = 0
		self.framePointers  = []
		self.historyStack   = []
		self.resetFlag	    = true
	}
		
	/// Run single instruction on assembly progrma,
	/// the run ekecution is step by step
	func runStep(optionsSource: options_t) -> ExecutionStatus {
		if programCounter >= optionsSource.text_vaddr &&
			programCounter < optionsSource.text_vaddr + UInt32(optionsSource.text_size) {
			
			return executeSingleInstruction(optionsSource: optionsSource)
		}
		
		return .success
	}
	
	/// Execute single instruction
	private func executeSingleInstruction(
		optionsSource: options_t
	) -> ExecutionStatus {
		
		// Save current program counter
		let oldPC = self.programCounter
		
		var nextProgramCounter = self.programCounter + 4
		
		let rawInstruction = fetch(optionsSource: optionsSource)
				
		if rawInstruction == -1 {
			return .instructionFetchFailed
		}
		
		let decodedInstruction = decode(Int(rawInstruction))
		
		let controlUnitState = getControlSignals(decodedInstruction.operationCode)
		
		let aluOperation = alu.getOperation(
			controlUnitState.operation,
			funz3: decodedInstruction.funz3,
			funz7: decodedInstruction.funz7
		)
		
		if aluOperation == .unknown {
			return .invalidOperation
		}
		
		var firstOperand  = 0
		var secondOperand = 0
		var resultAlu 	  = ResultAlu32Bit()
		
		// MARK: - Calc operation
		if aluOperation != .skip {
			
			firstOperand = if controlUnitState.operation == 0x17 {
				Int(programCounter)
				
			} else {
				getValueRegister(Int(decodedInstruction.registerSource1))
			}
			
			secondOperand = if controlUnitState.alu_src {
				decodedInstruction.immediate
				
			} else {
				getValueRegister(Int(decodedInstruction.registerSource2))
			}
			
			resultAlu = alu.execute(
				a	     : firstOperand,
				b		 : secondOperand,
				less	 : false,
				operation: aluOperation
			)
		}
		
		// 1100 1110 -> 0x67, f3 -> = jalr && 6F -> jal
				
//		if (decodedInstruction.operationCode == 0x67 &&
//			decodedInstruction.funz3 == 0) 			 ||
//			decodedInstruction.operationCode == 0x6F
		if decodedInstruction.type == .upperJump {
			
			let change = StateChange(
				oldProgramCounter: oldPC,
				target: .register(
					index: Int(decodedInstruction.registerDestination)
				),
				oldValue: registers[Int(decodedInstruction.registerDestination)]
			)
			
			historyStack.append(change)
			
			if controlUnitState.reg_write {
				if !writeRegister(
					value: Int(nextProgramCounter),
					destination: Int(decodedInstruction.registerDestination)
				) {
					return .registerWriteFailed
				}
			}
			
			nextProgramCounter = UInt32(
				decodedInstruction.operationCode == 0x6F ?
					Int(programCounter) + secondOperand & ~1:
					firstOperand + secondOperand & ~1
			)
			
			programCounter = nextProgramCounter
			return .success
		}
		
		// ecall instruction
		if controlUnitState.reg_write && aluOperation == .skip {
			let change = StateChange(
				oldProgramCounter: oldPC,
				target: .register(
					index: Int(decodedInstruction.registerDestination)
				),
				oldValue: registers[Int(decodedInstruction.registerDestination)]
			)
			
			historyStack.append(change)
			
			if !writeRegister(
				value: decodedInstruction.immediate,
				destination: Int(decodedInstruction.registerDestination)
				
			) { return .registerWriteFailed }
			
			programCounter = nextProgramCounter
			return .success
		}
		
		// if controlUnitState.mem_read && controlUnitState.alu_src
		if controlUnitState.mem_read && controlUnitState.alu_src {
			let valueRamRead = read_ram32bit(ram, UInt32(resultAlu.result))
			
			if valueRamRead == -1 {
				return .ramReadFailed
			}
			
			let change = StateChange(
				oldProgramCounter: oldPC,
				target: .register(index: Int(decodedInstruction.registerDestination)),
				oldValue: registers[Int(decodedInstruction.registerDestination)]
			)
			historyStack.append(change)
						
			if !writeRegister(value: Int(valueRamRead), destination: Int(decodedInstruction.registerDestination)) {
				return .registerWriteFailed
			}
			
		} else if controlUnitState.mem_write && controlUnitState.alu_src {
			// Calculate memory address: base(rs1) + offset(immediate)
		    let memoryAddress = UInt32(resultAlu.result)
			let registerSource2 = Int(decodedInstruction.registerSource2)
		   
		    // Get value to store from rs2
		    let valueToStore = getValueRegister(
				Int(decodedInstruction.registerSource2)
			)
			
			let sp = UInt32(registers[2])
			if memoryAddress >= sp && memoryAddress < sp + 512 {
				stackStores[memoryAddress] = registerSource2
			}
			
			let originalValue = read_ram32bit(ram, memoryAddress)
			let change = StateChange(
				oldProgramCounter: oldPC,
				target: .memory(address: memoryAddress),
				oldValue: Int(originalValue)
			)
			historyStack.append(change)
		   
		   // Perform store based on funct3
		   if !performStore(address: memoryAddress, value: valueToStore, funct3: decodedInstruction.funz3) {
			   return .ramStoreFailed
		   }
			
		} else if controlUnitState.reg_write {
			let change = StateChange(
				oldProgramCounter: oldPC,
				target: .register(index: Int(decodedInstruction.registerDestination)),
				oldValue: registers[Int(decodedInstruction.registerDestination)]
			)
			historyStack.append(change)
			
			if !writeRegister(value: resultAlu.result, destination: Int(decodedInstruction.registerDestination)) {
				return .registerWriteFailed
			}
		}
		
		programCounter = nextProgramCounter
		
		return .success
	}
	
	func backwardExecute() {
		
		guard let lastChange = historyStack.popLast() else {
			print("Cronology is empty. Not possible execute backward instruction.")
			return
		}
		
		self.programCounter = lastChange.oldProgramCounter
		
		switch lastChange.target {
			case .register(index: let index):
				_ = writeRegister(value: lastChange.oldValue, destination: index)
				
			case .memory(address: let address):
				write_ram32bit(ram, address, UInt32(lastChange.oldValue))
			
			case .none:
				break
		}		
	}
	
	/// Fetch instruction in ram
	private func fetch(optionsSource: options_t) -> Int32 {
		
		if programCounter < optionsSource.text_vaddr || programCounter >= Int(optionsSource.text_vaddr) + optionsSource.text_size {
			print("Invalid program counter, outside the text section");
			return -1;
		}

		if ((programCounter % 4) != 0) {
			print("Program counter must be aligned to 4 bytes for RISC-V instructions");
			return -1;
		}

		return read_ram32bit(ram!, UInt32(programCounter));
	}
	
	/// Decode language code instruction
	func decode(_ instruction: Int) -> DecodedInstruction {
		
		var decoded = DecodedInstruction(
			operationCode: UInt8(extractBits(instruction, start: 0, end: 6)),
			registerSource1: UInt8(extractBits(instruction, start: 15, end: 19)),
			registerSource2: UInt8(extractBits(instruction, start: 20, end: 24)),
			registerDestination: UInt8(extractBits(instruction, start: 7, end: 11)),
			immediate: 0,
			funz3: UInt8(extractBits(instruction, start: 12, end: 14)),
			funz7: UInt8(extractBits(instruction, start: 30, end: 30)),
			type: .notDefined
		)
		
		switch decoded.operationCode {
				
			// Immediate instruction
			case 0x67, 0x13, 0x03:
				let extractedBits = extractBits(instruction, start: 20, end: 31)
				decoded.immediate = signExtend(value: extractedBits, bits: 12)
							
				decoded.type = .immediate
				
			// Store instruction
			case 0x23:
				let immediateAt11To5   = extractBits(instruction, start: 25, end: 31)
				let immediateAt4To0    = extractBits(instruction, start: 7, end: 11)
				let calculateImmediate = immediateAt11To5 << 5 | immediateAt4To0
				
				decoded.immediate = signExtend(value: calculateImmediate, bits: 12)
				
				// FIXME: - Added recently
				decoded.type = .store
				
			// Upper jump instruction
			case 0x6F:
				let immediateAt20 = extractBits(
					instruction,
					start: 31,
					end  : 31
				)
				let immediateAt19To12 = extractBits(instruction, start: 12, end: 19)
				let immediateAt11 = extractBits(instruction, start: 20, end: 20)
				let immediateAt10To1 = extractBits(instruction, start: 21, end: 30)
				let calculateImmediate = immediateAt20 << 20 | immediateAt19To12 << 12 | immediateAt11 << 11 | immediateAt10To1 << 1
				
				decoded.immediate = signExtend(value: calculateImmediate, bits: 21)
				
				// FIXME: - Added recently
				decoded.type = .upperJump
				
			// Upper?
			case 0x37, 0x17:
				decoded.immediate = Int(extractBits(instruction, start: 12, end: 31) << 12)
				
				decoded.type = .upper
				
			default:
				decoded.immediate = 0
		}
		
		return decoded
	}
	
	/// Write value on register
	private func writeRegister(value: Int, destination registerNumber: Int) -> Bool {
		if registerNumber <= 0 || registerNumber >= 32 { return false }
		
		// Track when the frame pointer is saved (s0/fp = x8)
		if registerNumber == 8 {
			let sp = UInt32(registers[2])
			if !framePointers.contains(sp) {
				framePointers.append(sp)
			}
		}
		
		registers[registerNumber] = value
		return true
	}
	
	/// Get register value
	private func getValueRegister(_ indexRegister: Int) -> Int {
		if indexRegister < 0 || indexRegister >= 32 { return -1 }
		
		return registers[indexRegister]
	}
	
	private func extractBits(_ instruction: Int, start: Int, end: Int) -> Int {
		return instruction >> start & ((1 << (end - start + 1)) - 1);
	}
	
	private func signExtend(value: Int, bits: Int) -> Int {
		let mask = (1 << bits) - 1
		let maskedValue = value & mask
		
		let signBit = (maskedValue >> (bits - 1)) & 1
		
		if signBit == 1 {
			// Negativo number: extend with 1
			let extensionNumber = ~mask
			return maskedValue | extensionNumber
			
		} else {
			// Positivo number: return self
			return maskedValue
		}
	}
	
	func loadEntryPoint(value: UInt32) {
		self.programCounter = value
	}
	
	/// Perform store operation based on funct3 (store size)
	/// - Parameters:
	///   - address: Memory address where to store
	///   - value: Value to store
	///   - funct3: Function code that determines store size (0=SB, 1=SH, 2=SW)
	/// - Returns: True if store was successful, false otherwise
	private func performStore(address: UInt32, value: Int, funct3: UInt8) -> Bool {
		guard let ram = ram else {
			print("RAM not initialized")
			return false
		}
		
		let sp = UInt32(registers[2])
		if address >= sp && address < sp + 512 {
			for i in 0 ..< 32 {
				if registers[i] == value {
					stackStores[address] = i
					break
				}
			}
		}
		
		switch funct3 {
		case 0x0: // SB - Store Byte
			return storeByte(ram: ram, address: address, value: UInt8(value & 0xFF))
			
		case 0x1: // SH - Store Halfword (2 bytes)
			return storeHalfword(ram: ram, address: address, value: UInt16(value & 0xFFFF))
			
		case 0x2: // SW - Store Word (4 bytes)
			write_ram32bit(ram, address, UInt32(bitPattern: Int32(value)))
			return true
			
		default:
			print("Unknown store instruction with funct3: 0x\(String(format: "%x", funct3))")
			return false
		}
	}

	/// Store a single byte to memory
	/// - Parameters:
	///   - ram: RAM instance
	///   - address: Memory address
	///   - value: Byte value to store
	/// - Returns: True if successful
	private func storeByte(ram: RAM, address: UInt32, value: UInt8) -> Bool {
		let ramBase = ram.pointee.base_vaddr
		let ramSize = ram.pointee.size
		
		if address < ramBase {
			print("Store byte: address 0x\(String(format: "%08x", address)) below RAM base 0x\(String(format: "%08x", ramBase))")
			return false
		}
		
		let offset = address - ramBase
		if offset >= ramSize {
			print("Store byte: address 0x\(String(format: "%08x", address)) out of bounds")
			return false
		}
		
		ram.pointee.data[Int(offset)] = value
		return true
	}

	/// Store a halfword (2 bytes) to memory in little-endian format
	/// - Parameters:
	///   - ram: RAM instance
	///   - address: Memory address (must be 2-byte aligned)
	///   - value: Halfword value to store
	/// - Returns: True if successful
	private func storeHalfword(ram: RAM, address: UInt32, value: UInt16) -> Bool {
		if (address % 2) != 0 {
			print("Store halfword: address 0x\(String(format: "%08x", address)) not aligned to 2 bytes")
			return false
		}
		
		let ramBase = ram.pointee.base_vaddr
		let ramSize = ram.pointee.size
		
		if address < ramBase {
			print("Store halfword: address 0x\(String(format: "%08x", address)) below RAM base")
			return false
		}
		
		let offset = address - ramBase
		if offset + 1 >= ramSize {
			print("Store halfword: address 0x\(String(format: "%08x", address)) out of bounds")
			return false
		}
		
		ram.pointee.data[Int(offset)] = UInt8(value & 0xFF)
		ram.pointee.data[Int(offset + 1)] = UInt8((value >> 8) & 0xFF)
		return true
	}
	
}
