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
	@Published var stackFrames   : [StackFrame] = []
	@Published var programCounter: UInt32
	@Published var stackStores   : [UInt32: Int] = [:] // address -> register number
	
	var registers: [Int]
	private let resetFlag: Int
	private let alu: ALU
	var ram: RAM? = nil
	
	var textBase: UInt32 = 0
	var textSize: UInt32 = 0
	var dataBase: UInt32 = 0
	var dataSize: UInt32 = 0
	
	private var lastSP: UInt32 = 0
	private var lastFP: UInt32 = 0
	private var stackUpdateCounter: Int = 0
	
	// Tracking frame pointer for identify each frame
	private var framePointers: [UInt32] = []
	
	init() {
		self.programCounter = 0
		self.resetFlag = -1
		self.registers = [Int](repeating: 0, count: 32)
		self.alu = ALU()
	}
	
	func initRam(ram: RAM) { self.ram = ram }
	
	/// Run code step by step
	func runStep(optionsSource: options_t) -> Bool {
		if programCounter >= optionsSource.text_vaddr &&
			programCounter < optionsSource.text_vaddr + UInt32(optionsSource.text_size) {
			
			return execute(optionsSource: optionsSource)
		}
		
		return false
	}
	
	/// Execute single istruction
	private func execute(optionsSource: options_t) -> Bool {
		defer { updateStackFrames() }

		var nextProgramCounter = programCounter + 4
		
		let rawInstruction = fetch(optionsSource: optionsSource)
				
		if rawInstruction == -1 {
			return false
		}
		
		let decodedInstruction = decode(Int(rawInstruction))
		
		let controlUnitState = getControlSignals(decodedInstruction.operationCode)
		
		let aluOperation = alu.getOperation(
			controlUnitState.operation,
			funz3: decodedInstruction.funz3,
			funz7: decodedInstruction.funz7
		)
		
		if aluOperation == .unknown {
			print("Invalid operation")
			return false
		}
		
		var firstOperand = 0
		var secondOperand = 0
		var resultAlu: ResultAlu32Bit = ResultAlu32Bit(result: 0, zero: false, overflow: false)
		
		if aluOperation != .skip {
			
			firstOperand = controlUnitState.operation == 0x17 ? Int(programCounter) : getValueRegister(register: Int(decodedInstruction.registerSource1))
			
			secondOperand = controlUnitState.alu_src ? decodedInstruction.immediate : getValueRegister(register: Int(decodedInstruction.registerSource2))
						
			resultAlu = alu.execute(a: firstOperand, b: secondOperand, less: false, operation: aluOperation)
		}
		
		if (decodedInstruction.operationCode == 0x67 && decodedInstruction.funz3 == 0) ||
			decodedInstruction.operationCode == 0x6F {
			
			if controlUnitState.reg_write {
				if !writeRegister(value: Int(nextProgramCounter), destination: Int(decodedInstruction.registerDestination)) {
					return false
				}
			}
			
			nextProgramCounter = UInt32(decodedInstruction.operationCode == 0x6F ?
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
			
		} else if controlUnitState.mem_write && controlUnitState.alu_src {
			// Calculate memory address: base(rs1) + offset(immediate)
		    let memoryAddress = UInt32(resultAlu.result)
			let registerSource2 = Int(decodedInstruction.registerSource2)
		   
		    // Get value to store from rs2
		    let valueToStore = getValueRegister(register: Int(decodedInstruction.registerSource2))
			
			let sp = UInt32(registers[2])
			if memoryAddress >= sp && memoryAddress < sp + 512 {
				stackStores[memoryAddress] = registerSource2
			}
		   
		   // Perform store based on funct3
		   if !performStore(address: memoryAddress, value: valueToStore, funct3: decodedInstruction.funz3) {
			   print("Store instruction failed")
			   return false
		   }
			
		} else if controlUnitState.reg_write {
			if !writeRegister(value: resultAlu.result, destination: Int(decodedInstruction.registerDestination)) {
				return false
			}
		}
		
		programCounter = nextProgramCounter
		
		return true
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
			funz7: UInt8(extractBits(instruction, start: 30, end: 30))
		)
		
		switch decoded.operationCode {
			case 0x67, 0x13, 0x03:
				let extractedBits = extractBits(instruction, start: 20, end: 31)
				decoded.immediate = signExtend(value: extractedBits, bits: 12)
							
			// Store instruction
			case 0x23:
				let immediateAt11To5   = extractBits(instruction, start: 25, end: 31)
				let immediateAt4To0    = extractBits(instruction, start: 7, end: 11)
				let calculateImmediate = immediateAt11To5 << 5 | immediateAt4To0
				
				decoded.immediate = signExtend(value: calculateImmediate, bits: 12)
				
			case 0x6F:
				let immediateAt20 = extractBits(instruction, start: 31, end: 31)
				let immediateAt19To12 = extractBits(instruction, start: 12, end: 19)
				let immediateAt11 = extractBits(instruction, start: 20, end: 20)
				let immediateAt10To1 = extractBits(instruction, start: 21, end: 30)
				let calculateImmediate = immediateAt20 << 20 | immediateAt19To12 << 12 | immediateAt11 << 11 | immediateAt10To1 << 1
				
				decoded.immediate = signExtend(value: calculateImmediate, bits: 21)
				
			case 0x37, 0x17:
				decoded.immediate = Int(extractBits(instruction, start: 12, end: 31) << 12)
				
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
	private func getValueRegister(register indexRegister: Int) -> Int {
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
	
	@MainActor
	private func updateStackFrames() {
		guard let ram = ram else { return }
		
		let sp = UInt32(registers[2])
		let fp = UInt32(registers[8])
		
		// Aggiorna solo ogni N istruzioni O se SP/FP cambiano significativamente
		stackUpdateCounter += 1
		let spChanged = abs(Int(sp) - Int(lastSP)) >= 4 // Minimo 1 words di differenza
		let fpChanged = fp != lastFP
		
		// Aggiorna solo se necessario
		guard stackUpdateCounter >= 2 || spChanged || fpChanged else {
			return
		}
		
		stackUpdateCounter = 0
		lastSP = sp
		lastFP = fp
				
		// Ora procedi con l'aggiornamento reale
		var frames: [StackFrame] = []
		
		let wordsToShow = 128
		var consecutiveErrors = 0
		let maxConsecutiveErrors = 8
		
		let ramStart = ram.pointee.base_vaddr
		let ramEnd = ramStart + UInt32(ram.pointee.size)

		for i in 0..<wordsToShow {
			let addr = sp &+ UInt32(i * 4)
			
			if addr < ramStart || addr + 4 > ramEnd {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
				continue
			}
			
			let rawInstruction = read_ram32bit(ram, addr)
			let isError = (rawInstruction == -1)
			
			let isNonZero = (!isError && rawInstruction != 0)
			let rawInstructionUnsigned = UInt32(bitPattern: rawInstruction)
			
			let isPointerToText = (
				rawInstructionUnsigned >= self.textBase &&
				rawInstructionUnsigned < self.textBase &+ self.textSize
			)
			
			let isFrameBoundary = isPointerToText && isNonZero
			let isFramePointer = (addr == fp)
			let isSavedRegister = isNonZero && !isPointerToText && i < 32

			if isError {
				consecutiveErrors += 1
				if consecutiveErrors >= maxConsecutiveErrors { break }
				
			} else {
				consecutiveErrors = 0
				
			}

			let color: Color
			if isError {
				color = Color(.systemGray)
			} else if isFramePointer {
				color = Color(.systemPurple).opacity(0.85)
			} else if isFrameBoundary {
				color = Color(.systemRed).opacity(0.85)
			} else if isSavedRegister {
				color = Color(.systemOrange).opacity(0.6)
			} else if isNonZero {
				color = Color(.systemBlue).opacity(0.6)
			} else {
				color = Color(.systemMint)
			}

			let frame = StackFrame(
				address: addr,
				value: rawInstruction,
				color: color,
				label: String(format: "0x%08x", addr),
				isPointer: isPointerToText,
				isNonZero: isNonZero,
				isError: isError,
				isFrameBoundary: isFrameBoundary,
				offsetFromSP: i
			)
			
			frames.append(frame)
		}

		// Usa animazione più leggera se i frame sono simili
		let animationStyle: Animation = frames.count == self.stackFrames.count ?
			.easeInOut(duration: 0.15) :
			.spring(response: 0.3, dampingFraction: 0.8)
		
		withAnimation(animationStyle) {
			self.stackFrames = frames
		}
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
	
	func getSavedRegistersInFrame(at frameStart: UInt32, size: Int) -> [(register: Int, value: Int32)] {
		guard let ram = ram else { return [] }
		var saved: [(Int, Int32)] = []
		
		let registerMap = [1, 8, 9, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27] // ra, s0-s11
		
		for (index, regNum) in registerMap.enumerated() {
			let addr = frameStart &+ UInt32(index * 4)
			let value = read_ram32bit(ram, addr)
			if value != -1 && value != 0 {
				saved.append((regNum, value))
			}
		}
		
		return saved
	}
}
