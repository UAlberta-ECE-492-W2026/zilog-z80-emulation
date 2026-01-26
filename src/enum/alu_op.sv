`ifndef ALU_OP
`define ALU_OP
typedef enum byte { 
    NOP,
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
    DEC 
} alu_op;
`endif
