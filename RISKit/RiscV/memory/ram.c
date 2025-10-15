/**
 * @file ram.c
 * @brief Implementation of RAM memory management functions.
 *
 * This file contains functions to create, free, write to, and read from RAM.
 */

#include <stdint.h>
#include "ram.h"

#include <stdlib.h>
#include <string.h>

void destroy_ram(RAM ram) {

    if (!ram) return;

    free(ram->data);
    free(ram);
}

/**
 * @brief Create a new RAM instance with the specified size.
 * @param size Size of the RAM in bytes.
 *
 * @return Pointer to the newly created RAM instance, or NULL if allocation fails.
 */
RAM new_ram(size_t size) {
    if (size == 0) return NULL;

    RAM main_memory = malloc(sizeof(struct ram));

    if (!main_memory) return NULL;

    main_memory->data = (u_int8_t *)malloc(size);
    if (!main_memory->data) {
        free(main_memory);
        return NULL;
    }

    main_memory->size = size;

    memset(main_memory->data, 0, size);
    return main_memory;

}

/**
 * @brief Free the RAM instance and its data.
 * @param ram Pointer to the RAM instance to be freed.
 */
void free_ram(RAM ram) {
    free(ram->data);
    ram->data = NULL;
    ram->size = 0;

}

/**
 * @brief Write a 32-bit value to the specified address in RAM.
 * @param ram Pointer to the RAM instance.
 * @param address Address in RAM where the value will be written.
 * @param value 32-bit value to write to RAM.
 */
void write_ram32bit(
          RAM      ram,
    const uint32_t address,
    const uint32_t value
) {

    if (!ram || !ram->data) {
        fprintf(stderr, "Errore: RAM non inizializzata\n");
        return;
    }

    if (address % 4 != 0) {
        fprintf(stderr, "Errore: indirizzo 0x%08x non allineato a 4 byte\n", address);
        return;
    }

    if (address + 3 >= ram->size) {
        fprintf(stderr, "Errore: accesso fuori bounds 0x%08x + 4 > 0x%08x\n",
                address, (int32_t)ram->size);
        return;
    }

    uint8_t *p = ram->data + address;

    p[0] = (uint8_t)(value & 0xFF);
    p[1] = (uint8_t)(value >> 8 & 0xFF);
    p[2] = (uint8_t)(value >> 16 & 0xFF);
    p[3] = (uint8_t)(value >> 24 & 0xFF);
}

/**
 * @brief Read a 32-bit value from the specified address in RAM.
 * @param ram Pointer to the RAM instance.
 * @param address Address in RAM from which the value will be read.
 *
 * @return The 32-bit value read from RAM.
 */
int32_t read_ram32bit(
          RAM ram,
    const uint32_t address
) {
    if (!ram || !ram->data) {
        fprintf(stderr, "Errore: RAM non inizializzata\n");
        return -1;
    }

    if (address % 4 != 0) {
        fprintf(stderr, "Errore: indirizzo 0x%08x non allineato a 4 byte\n", address);
        return -1;
    }

    if (address + 3 >= ram->size) {
        fprintf(stderr, "Errore: accesso fuori bounds 0x%08x + 4 > 0x%08lu\n",
                address, ram->size);
        return -1;
    }

    const uint8_t *p = ram->data + address;

    return (int32_t)p[0]
         | (int32_t)p[1] << 8
         | (int32_t)p[2] << 16
         | (int32_t)p[3] << 24;

}

void load_binary_to_ram(RAM ram, const uint8_t *binary, size_t size, uint32_t start_addr) {
    if (!ram) {
        fprintf(stderr, "RAM pointer null\n");
        return;
    }
    
    if (!binary) {
        fprintf(stderr, "Binary pointer null\n");
        return;
    }

    // Controllo bounds più rigoroso
    if (start_addr >= ram->size) {
        fprintf(stderr, "Indirizzo di start 0x%08x fuori dai limiti della RAM (0x%08x)\n",
                start_addr, (int32_t)ram->size);
        return;
    }

    if (start_addr + size > ram->size) {
        fprintf(stderr, "Dimensione %zu + indirizzo 0x%08x eccede la RAM (0x%08x)\n",
                size, start_addr, (int32_t)ram->size);
        size = ram->size - start_addr; // Tronca alla dimensione disponibile
    }

    // Copia byte per byte
    for (size_t i = 0; i < size; i++) {
        ram->data[start_addr + i] = binary[i];
    }

}
