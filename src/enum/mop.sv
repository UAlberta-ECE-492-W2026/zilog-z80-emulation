`ifndef UOP
`define UOP
// enum for decoded instruciton opcodes. Based off the original names.
//
// One major difference is that special characters like () and spaces can't be used in code
// in place of spaces '_' has been used. in place of () register names are prefixed with 'm'
// the secondary registers (e.g. AF') are denoted with the 'p' suffix
//
// Some similar instructions have been combined into one uop. For example LD r (HL) and LD r (IX+d) 
// are both denoted as LD_R_mRd, where R denotes a generic register, not just one of the general
// purpose registers. This results in some isntructions like LD_R_R repeating 'R', despite reffering
// to two different registers.

typedef enum [6:0] { 
// misc
    INVALID,

// load
    LD_R_R,
    LD_R_nn,
    LD_R_mRd,
    LD_mRd_R,
    LD_mRd_n,
    LD_R_mnn,
    LD_mnn_R,
    LD_mnn_RL,
    PUSH_R,
    POP_R,

// Exchange, Block Transfer, and Search
    EX_DE_HL,
    EX_AF_AFp,
    EXX,
    EX_mR_R,
    LD_block,
    CP_block,

// Arithmetic
    ADD_R_R,
    ADD_R_nn,
    ADD_R_mRd,
    ADC_R_R,
    ADC_R_nn,
    ADC_R_mRd,
    SUB_R_R,
    SUB_R_nn,
    SUB_R_mRd,
    SBC_R_R,
    SBC_R_nn,
    SBC_R_mRd,
    AND_R_R,
    AND_R_nn,
    AND_R_mRd,
    OR_R_R,
    OR_R_nn,
    OR_R_mRd,
    XOR_R_R,
    XOR_R_nn,
    XOR_R_mRd,
    CP_R_R,
    CP_R_nn,
    CP_R_mRd,
    INC_mRd,
    DEC_mRd,

//General-Purpose Arithmetic and CPU Control
    DAA,
    CPL,
    NEG,
    CCF,
    SCF,
    NOP,
    HALT,
    DI,
    EI,
    IM0,
    IM1,
    IM2,

// Rotate and Shift
    RLC_R,
    RLC_mRd,
    RL_R,
    RL_mRd,
    RRC_R,
    RRC_mRd,
    RR_R,
    RR_mRd,
    SLA_R,
    SLA_mRd,
    SRA_R,
    SRA_mRd,
    SRL_R,
    SRL_mRd,
    RLD,
    RRD,

// Bit Set, Reset, and Test
    BIT_b_R,
    BIT_b_mRd,
    SET_b_R,
    SET_b_mRd,
    RES_b_R,
    RES_b_mRd,

// Jump 
    JP_nn,
    JP_cc_nn,
    JR_e,
    JR_cc_e,
    JP_R,
    DJNZ_e,

// Call and Return
    CALL_nn,
    CALL_cc_nn,
    RET,
    RET_cc,
    RETI,
    RETN,
    RST_p,

// Input and Output Group
    IN_R_mn,
    IN_R_mR,
    INI,
    INIR,
    IND,
    INDR,
    OUT_mn_R,
    OUT_mR_R,
    OUTI,
    OTIR,
    OUTD,
    OTDR // not being able to add a trailing comma here is sad
} mop;
`endif
