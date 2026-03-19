`ifndef ALU_OP
`define ALU_OP

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum [4:0] { 
    ALU_NOP,
    ALU_ADD, 
    ALU_SUB, 
    ALU_AND, 
    ALU_OR, 
    ALU_XOR, 
    ALU_COMPARE, 
    ALU_SLL, 
    ALU_SRL, 
    ALU_SLA, 
    ALU_SRA, 
    ALU_ROL, 
    ALU_ROR, 
    ALU_INC, 
    ALU_DEC,
    ALU_BIT,
    ALU_SETBIT,
    ALU_RESBIT,
    ALU_PASS_A,
    ALU_PASS_B
} alu_op;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
