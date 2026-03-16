`timescale 1ns/1ps

module controller_next_state (
                              c_to_dp_intf.next_state_logic ctrl_intf,
                              input wire reset_sig
);
    import uop::*;
    always_comb begin: next_state_block
        ctrl_intf.next_state = ctrl_intf.current_state;
        if (reset_sig) ctrl_intf.next_state = uop::reset;
    end;


endmodule; // controller_next_state
