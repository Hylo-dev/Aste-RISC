//
//  ErrorExecution.swift
//  Aste-RISC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 02/11/25.
//

enum ExecutionStatus: String {
	case success                  = "Execution completed successfully."
	case instructionFetchFailed   = "Failed to fetch instruction."
	case invalidOperation         = "Invalid or unsupported operation."
	case registerWriteFailed      = "Failed to write to register."
	case ramReadFailed            = "Failed to read from RAM."
	case ramStoreFailed           = "Failed to store value in RAM."
}
