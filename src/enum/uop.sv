`ifndef UOP
`define UOP
/**
 enum for the uop (micro-operation). These represents the states that the
 controller may take, which in turn defines the output of the controller.

 One major difference is that special characters like () and spaces can't be used in code
 in place of spaces '_' has been used. in place of () register names are prefixed with 'm'
 the secondary registers (e.g. AF') are denoted with the 'p' suffix

 Some similar instructions have been combined into one uop. For example LD r (HL) and LD r (IX+d)
 are both denoted as LD_R_mRd, where R denotes a generic register, not just one of the general
 purpose registers. This results in some isntructions like LD_R_R repeating 'R', despite reffering
to two different registers.
*/
typedef enum [7:0] {
// misc
    invalid_uop,
    reset_uop
    
    } uop ;
`endif
