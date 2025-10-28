//
// Created by C4V4H.exe on 10/06/25.
//

#include <stdio.h>
#include <getopt.h>
#include <ctype.h>

#include "args_handler.h"
#include "asm_file_parser.h"

static char **split_args(const char *args_str, int *count);
static void add_breakpoint(options_t *opts, const char *addr);


void print_options(const options_t *opts) {
    if (opts->args_count > 0 && opts->args != NULL) {
        printf("Binary arguments: ");
        for (int i = 0; i < opts->args_count; i++) {
            printf("%s ", opts->args[i]);
        }
        printf("\n");
    }

    if (opts->breakpoint_count > 0 && opts->breakpoints != NULL) {
        printf("Breakpoints: ");
        for (int i = 0; i < opts->breakpoint_count; i++) {
            printf("%s ", opts->breakpoints[i]);
        }
        printf("\n");
    }
}

/**
 * @brief splits the args str
 * @param args_str string containing the args
 * @param count number of the args
 * @return separated args
 */
char** split_args(const char *args_str, int *count) {
    if (!args_str) {
        *count = 0;
        return NULL;
    }

    // count the arg number
          char *temp  = strdup(args_str);
    const char *token = strtok(temp, " ");

    *count = 0;
    while (token) {
        (*count)++;
        token = strtok(NULL, " ");
    }
    free(temp);

    if (*count == 0) return NULL;

    char **argv = malloc((*count + 1) * sizeof(char*));

    temp = strdup(args_str);
    token = strtok(temp, " ");
    int i = 0;
    while (token && i < *count) {
        argv[i] = strdup(token);
        token = strtok(NULL, " ");
        i++;
    }
    argv[*count] = NULL;

    free(temp);
    return argv;
}

/**
 * @brief adds in the options the list of the breakpoints to add
 * @param opts options
 * @param addr address where to add a breakpoint
 */
void add_breakpoint(options_t *opts, const char *addr) {
    opts->breakpoint_count++;
    char** breakpoints = realloc(opts->breakpoints,
                               opts->breakpoint_count * sizeof(char*));
    if (!breakpoints) return;
    opts->breakpoints = breakpoints;
    opts->breakpoints[opts->breakpoint_count - 1] = strdup(addr);
}


/**
 * @brief free options
 * @param opts options obj to free
 */
void free_options(options_t *opts) {
    if (!opts) return;

    if (opts->binary_file) free(opts->binary_file);

    if (opts->args) {
        for (int i = 0; i < opts->args_count; i++) {
            free(opts->args[i]);
        }
        free(opts->args);
    }

    if (opts->breakpoints) {
        for (int i = 0; i < opts->breakpoint_count; i++) {
            free(opts->breakpoints[i]);
        }
        free(opts->breakpoints);
    }

    if (opts->text_data) free(opts->text_data);


    if (opts->data_data) free(opts->data_data);

    free(opts);
}

/**
 * @brief handle the program's args
 * opts options (obj containing the options)
 * 1: printed help. 0: success, -1: error occurred
 */
options_t* start_options(char *url) {
    
    options_t* opts = calloc(1, sizeof(options_t));
    
    if (!opts) { return NULL; }

    opts->execution_mode = STEP_BY_STEP;        
    opts->binary_file    = url;

    // check if the binary has been passed
    if (!opts->binary_file) {
        fprintf(stderr, "Error: No binary file specified\n");

        return NULL;
    }
	
	// Assembling the binary
//	if (parse_riscv_file(opts) == -1)
//		return NULL;

    return opts;
}
