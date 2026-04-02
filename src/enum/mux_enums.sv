`ifndef MUX_ENUMS
`define MUX_ENUMS

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum {
    A_MUX_NOP,
    A_MUX_O_BUFF,
    A_MUX_REG_SHIFTED,
    A_MUX_REG,
    A_MUX_MEMORY_READ_BUFF,
    A_MUX_0
} alu_mux_a_enum;

typedef enum {
    B_MUX_NOP,
    B_MUX_IMM,
    B_MUX_INSTRUCTION_LENGTH,
    B_MUX_REG,
    B_MUX_MEMORY_READ_BUFF
} alu_mux_b_enum;

typedef enum {
    WB_MUX_NOP,
    WB_MUX_MEMORY,
    WB_MUX_MEMORY_READ_BUFF,
    WB_MUX_ALU
} write_back_enum;

typedef enum {
                    MEM_MUX_NOP,
                    MEM_MUX_BUFFERED,
                    MEM_MUX_BUFFERED_P1,
                    MEM_MUX_UNBUFFERED,
                    MEM_MUX_UNBUFFERED_P1
                    } mem_mux_enum;

typedef enum {
    MEM_DATA_MUX_NOP,
    MEM_DATA_MUX_UPPER,
    MEM_DATA_MUX_LOWER
} mem_data_mux_enum;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
