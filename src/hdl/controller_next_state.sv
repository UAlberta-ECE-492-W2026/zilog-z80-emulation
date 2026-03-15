`timescale 1ns/1ps

module controller_next_state (
                              output     uop::uop_t next_state,
                              input      uop::uop_t current_state,
                              input wire reset_sig
);
    import uop::*;
    always_comb begin: next_state_block
        next_state = current_state;
        if (reset_sig) next_state = uop::reset;
    end;


endmodule; // controller_next_state
