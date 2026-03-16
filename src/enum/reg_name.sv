`ifndef REG_NAMES
`define REG_NAMES

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum [4:0] { 
    NONE,
    ZERO,
    A,
    B,
    D,
    H,
    F,
    C,
    E,
    L,
    AF,
    BC,
    DE,
    HL,
    I,
    R,
    IX,
    IY,
    SP,
    PC
} reg_name;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
