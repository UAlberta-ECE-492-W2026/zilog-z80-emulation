`ifndef REG_NAMES
`define REG_NAMES

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

`endif
