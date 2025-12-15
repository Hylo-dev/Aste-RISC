//
//  assembler_with_logs.c
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/10/25.
//

#include "assembler_with_logs.h"

/**
 * @brief Execute command shell and send stdout/stderr to Swift using Callback function
 * @param cmd Pass command to execute
 * @param callback Function to get std outputs
 * @return -1 for errors, else retuls
 */
int run_command_with_log(
	const char *cmd,
	LogCallback callback
) {
	FILE *pipe = popen(cmd, "r");
	
	if (!pipe) {
		const assembler_message_t message = { MESSAGE_ERROR, "Failed to open process pipe" };
		callback(message);
		
		return -1;
	}

	char buffer[512];
	while (fgets(buffer, sizeof(buffer), pipe)) {
		assembler_message_t message;

		if (strstr(buffer, "warning:") != NULL) {
			message.type = MESSAGE_WARNING;
			
		} else if (strstr(buffer, "error:") != NULL) {
			message.type = MESSAGE_ERROR;
			message.text = strdup(buffer);
			callback(message);
			
			return -1;
			
		} else {
			message.type = MESSAGE_INFO;
			
		}

		message.text = strdup(buffer);
		callback(message);
	}

	const int status = pclose(pipe);
	
	return WEXITSTATUS(status);
}

/**
 * @brief Compile and link assembly RISC-V file, send log to Swift
 * @param filepath Path file to compile
 * @param output_elf_path Elf file assembled
 * @param callback Function passed for get std output
 */
int compile_assembly_with_log(
	const char *filepath,
	char *output_elf_path,
	LogCallback callback
) {
	
	char cmd[512]; // Command to execute
	char temp_obj[256];

	sprintf(
		temp_obj,
		"%s.o",
		filepath
	);
	
	sprintf(
		output_elf_path,
		"%s.elf",
		filepath
	);
    
    assembler_message_t message = { MESSAGE_INFO, "Assembling program..." };
    
    char* assembler_path = "/opt/homebrew/bin/riscv64-unknown-elf-as";
    if (access(assembler_path, X_OK) != 0) {
        fprintf(stderr, "Errore: Il binario '%s' non è stato trovato o non è eseguibile.\n", assembler_path);
        
        message.type = MESSAGE_ERROR;
        message.text = "ERROR: Assembler binary not found";
        callback(message);
        
        unlink(temp_obj);
        
        return -1;
    }

	// Compile (stdout + stderr)
	sprintf(
		cmd,
		"/opt/homebrew/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 \"%s\" -o \"%s\" 2>&1",
		filepath,
		temp_obj
	);
    
    callback(message);
	
	if (run_command_with_log(cmd, callback) != 0) {
		message.type = MESSAGE_ERROR;
		message.text = "Error during assembling";
		callback(message);
		
		unlink(temp_obj);
		
		return -1;
	}

	// Link program
	sprintf(
		cmd,
		"/opt/homebrew/bin/riscv64-unknown-elf-ld -G 0 -m elf32lriscv \"%s\" -o \"%s\" 2>&1",
		temp_obj,
		output_elf_path
	);
		
	message.type = MESSAGE_INFO;
	message.text = "Linking program...";
	callback(message);
	
	if (run_command_with_log(cmd, callback) != 0) {
		message.type = MESSAGE_ERROR;
		message.text = "Error during linking";
		unlink(temp_obj);
		
		return -1;
	}

	unlink(temp_obj);
	
	message.type = MESSAGE_INFO;
	message.text = "Assembly complete!";
	callback(message);
	
	return 0;
}
