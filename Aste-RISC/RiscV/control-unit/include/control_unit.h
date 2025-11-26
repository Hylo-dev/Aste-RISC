/**
 * @file control_unit.c
 * @brief Control unit for RISC-V instructions, this determinate the action CPU.
 *
 * @author eliorodr2104
 * @date 02/06/25
 *
 */

#ifndef CONTROLUNIT_H
#define CONTROLUNIT_H

#include <stdint.h>
#include <stdbool.h>

typedef enum {
	R_TYPE,
	I_TYPE,
	I_SAVE_TYPE,
	UJ_TYPE,
	S_TYPE,
	ECALL
	
} TypeInstruction;

/**
 * @struct ControlSignals
 * @brief Struct to hold control signals for the CPU
 *
 * branch Indicates if the instruction is a branch instruction
 * memRead Indicates if the instruction reads from memory
 * memToReg Indicates if the instruction writes to a register from memory
 * operation The operation code for the instruction
 * memWrite Indicates if the instruction writes to memory
 * aluSrc Indicates if the ALU uses an immediate value as source
 * regWrite Indicates if the instruction writes to a register
 *
 */
typedef struct {
    bool   		    branch;
    bool    		mem_read;
    bool    		mem_to_reg;
    uint8_t 		operation;
    bool    		mem_write;
    bool   		    alu_src;
    bool    		reg_write;
	TypeInstruction type;

} ControlSignals;

/**
 * @brief Get control signals based on the opcode.
 *
 * @param opcode The opcode of the instruction
 * @return ControlSignals structure with the control signals set
 */
ControlSignals getControlSignals(uint8_t opcode);
//ControlSignals getControlSignals(uint8_t opcode);

#endif //CONTROLUNIT_H
