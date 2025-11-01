//
//  assembler.h
//  RISKit
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/10/25.
//

#ifndef ASSEMBLER_H
#define ASSEMBLER_H

// assembler.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef enum {
	MESSAGE_INFO,
	MESSAGE_WARNING,
	MESSAGE_ERROR
} message_type_t;

typedef struct {
	message_type_t type;
	const char *text;
} assembler_message_t;

// Define the type that swift call
typedef void (*LogCallback)(assembler_message_t);

/**
 * @brief Execute command shell and send stdout/stderr to Swift using Callback function
 * @param cmd Pass command to execute
 * @param callback Function to get std outputs
 * @return -1 for errors, else retuls
 */
int run_command_with_log(
	const char *cmd,
	LogCallback callback
);

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
);

#endif
