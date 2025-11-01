//
// Created by C4V4H.exe on 10/06/25.
//

#include <ctype.h>

#include "args_handler.h"
#include "asm_file_parser.h"


/**
 * @brief free options
 * @param opts options obj to free
 */
void free_options(options_t *opts) {
    if (!opts) return;

    if (opts->binary_file) free(opts->binary_file);
    if (opts->text_data)   free(opts->text_data);
    if (opts->data_data)   free(opts->data_data);

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
	
	if (!url) {
		fprintf(stderr, "Error: No binary file specified (URL is NULL)\n");
		free(opts);
		return NULL;
	}

	opts->binary_file = strdup(url);
    if (!opts->binary_file) {
        fprintf(stderr, "Error: No binary file specified\n");
		free(opts);

        return NULL;
    }

    return opts;
}
