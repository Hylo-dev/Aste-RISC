/**
 * @file ram.c
 * @brief Implementation of RAM memory management functions.
 *
 * This file contains functions to create, free, write to, and read from RAM.
 */

#include "ram.h"

bool destroy_ram(RAM ram) {

    if (!ram) return false;

    free(ram->data);
    free(ram);
	
	return true;
}

/**
 * @brief Create a new RAM instance with the specified size.
 * @param size Size of the RAM in bytes.
 *
 * @return Pointer to the newly created RAM instance, or NULL if allocation fails.
 */
RAM new_ram(size_t size, uint32_t base_vaddr) {
    if (size == 0) return NULL;

    RAM main_memory = malloc(sizeof(struct ram));

    if (!main_memory) return NULL;

    main_memory->data = (u_int8_t *)malloc(size);
    if (!main_memory->data) {
        free(main_memory);
		
        return NULL;
    }

	main_memory->base_vaddr = base_vaddr;
    main_memory->size 		= size;

    memset(main_memory->data, 0, size);
    return main_memory;
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
	
	if (address < ram->base_vaddr) {
		fprintf(stderr, "Errore: indirizzo 0x%08x sotto base ram 0x%08x\n", address, ram->base_vaddr);
		return;
	}
	const uint32_t offset = address - ram->base_vaddr;

    if (offset + 3 >= ram->size) {
        fprintf(stderr, "Errore write: accesso fuori bounds 0x%08x + 4 > 0x%08x\n",
				offset, (int32_t)ram->size);
        return;
    }

    uint8_t *p = ram->data + offset;

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
	
	if (address < ram->base_vaddr) {
		fprintf(stderr, "Errore: indirizzo 0x%08x sotto base ram 0x%08x\n", address, ram->base_vaddr);
		return -1;
	}
	const uint32_t offset = address - ram->base_vaddr;

    if (offset + 3 >= ram->size) {
        fprintf(stderr, "Errore read: accesso fuori bounds 0x%08x + 4 > 0x%08lu\n",
                address, ram->size);
        return -1;
    }

    const uint8_t *p = ram->data + offset;
    return (int32_t)p[0]
         | (int32_t)p[1] << 8
         | (int32_t)p[2] << 16
         | (int32_t)p[3] << 24;

}

/**
 * @brief Load instructions into RAM from a binary data array,
 * starting from address 0x0.
 * @param ram Pointer to the RAM instance where instructions will be loaded.
 *
 */
void load_binary_to_ram(
		  RAM ram,
	const uint8_t *binary,
		  size_t size,
		  uint32_t start_addr
) {
	
	if (!ram || !binary) return;

	if (start_addr < ram->base_vaddr) {
		fprintf(stderr, "Start addr 0x%08x < base 0x%08x\n", start_addr, ram->base_vaddr);
		return;
	}

	uint32_t offset = start_addr - ram->base_vaddr;
	if ((uint64_t)offset >= ram->size) {
		fprintf(stderr, "Indirizzo di start 0x%08x fuori dai limiti della RAM (size 0x%08zx)\n",
				start_addr, ram->size);
		return;
	}

	if ((uint64_t)offset + size > ram->size) {
		fprintf(stderr, "Dimensione %zu + start 0x%08x eccede la RAM, tronco\n", size, start_addr);
		size = ram->size - offset;
	}

	memcpy(ram->data + offset, binary, size);
}

/**
 * @brief Load text section information into RAM.
 * @param ram Pointer to RAM struct where instructions will be loaded.
 * @param text_base Small address in text section.
 * @param text_size Size for text section into RAM.
 *
 */
void load_text_information(
	RAM      ram,
	uint32_t text_base,
	uint32_t text_size
) {
	if (!ram) return;
	
	ram->text_base = text_base;
	ram->text_size = text_size;
}

/**
 * @brief Load data section information into RAM.
 * @param ram Pointer to RAM struct where instructions will be loaded.
 * @param data_base Small address in data section.
 * @param data_size Size for data section into RAM.
 *
 */
void load_data_information(
	RAM      ram,
	uint32_t data_base,
	uint32_t data_size
) {
	if (!ram) return;
	
	ram->data_base = data_base;
	ram->data_size = data_size;
}
