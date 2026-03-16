`ifndef F_OP
`define F_OP

/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSEDSIGNAL */
typedef enum [1:0] {
    F_NOP,
    F_CCF,
    F_SCF
} f_op_enum;
/* verilator lint_on UNDRIVEN */
/* verilator lint_on UNUSEDSIGNAL */
`endif
