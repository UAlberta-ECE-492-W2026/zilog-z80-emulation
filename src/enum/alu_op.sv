`ifndef ALU_OP
`define ALU_OP

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum { 
    ALU_NOP,
    ALU_ADD, 
    ALU_SUB,
    ALU_ADC,
    ALU_SBC, 
    ALU_AND, 
    ALU_OR, 
    ALU_XOR, 
    ALU_COMPARE, 
    ALU_RLC, 
    ALU_RL, 
    ALU_RRC, 
    ALU_RR, 
    ALU_SLA, 
    ALU_SRA, 
    ALU_SRL,
    ALU_RLD,
    ALU_RRD,
    ALU_DEC,
    ALU_BIT,
    ALU_SETBIT,
    ALU_RESBIT,
    ALU_PASS_A,
    ALU_PASS_B,
    ALU_DAA,
    ALU_CPL,
    ALU_LDx // for LDI_block and LDD_block mops. these have special flag behavior.
} alu_op;

typedef enum { 
    NUMERIC_OP,
    SHIFT_OP, 
    ROTATE_OP,
    BCD_ROTATE_OP,
    AND_OP, 
    OR_OP, 
    XOR_OP, 
    DAA_OP,
    CPL_OP,
    LDx_OP
} alu_status_op;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
