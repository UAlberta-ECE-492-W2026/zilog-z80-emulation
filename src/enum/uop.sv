`ifndef UOP
`define UOP
/**
 enum for the uop (micro-operation). These represents the states that the
 controller may take, which in turn defines the output of the controller.

 This enum is primarily used by the controller next state logic and the output
 logic.
*/
typedef enum [7:0] {
// misc
    invalid_uop,
    reset_uop
    
    } uop ;
`endif
