//
// Created by C4V4H.exe on 10/06/25.
//

#ifndef ASM_FILE_PARSER_H
#define ASM_FILE_PARSER_H

#include <stdbool.h>

#include "args_handler.h"
#include "assembler_with_logs.h"

/**
 * @brief Check if the file has a .s extension
 * @param options_pointer options_t pointer to the options structure
 * @return true if the file has a .s extension, false otherwise
 */
int parse_riscv_file(options_t *options_pointer, LogCallback callback);

/**
 * @brief returns true if the file in the given path has .s extension
 * @param filepath path of file to parse
 * @return if the file has the .s extension
 */
bool is_assembly_file(const char *filepath);

#endif //ASM_FILE_PARSER_H
