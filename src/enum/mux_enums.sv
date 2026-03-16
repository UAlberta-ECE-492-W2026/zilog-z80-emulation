`ifndef MUX_ENUMS
`define MUX_ENUMS

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum [1:0] {
    A_MUX_NOP,
    A_MUX_O_BUFF,
    A_MUX_REG_SHIFTED,
    A_MUX_REG
} alu_mux_a_enum;

typedef enum [2:0] {
    B_MUX_NOP,
    B_MUX_IMM,
    B_MUX_INSTRUCTION_LENGTH,
    B_MUX_m2,
    B_MUX_m1,
    B_MUX_0,
    B_MUX_1,
    B_MUX_REG
} alu_mux_b_enum;

typedef enum [1:0] {
    WB_MUX_NOP,
    WB_MUX_MEMORY,
    WB_MUX_MEMORY_BUFF,
    WB_MUX_ALU
} write_back_enum;

typedef enum [1:0] {
    MEM_MUX_NOP,
    MEM_MUX_BUFFERED,
    MEM_MUX_UNBUFFERED
} mem_mux_enum;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
