`ifndef ALU_OP
`define ALU_OP

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum byte { 
    ALU_NOP,
    ADD, 
    SUB, 
    AND, 
    OR, 
    XOR, 
    COMPARE, 
    SLL, 
    SRL, 
    SLA, 
    SRA, 
    ROL, 
    ROR, 
    INC, 
    DEC,
    PASS_A,
    PASS_B
} alu_op;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
