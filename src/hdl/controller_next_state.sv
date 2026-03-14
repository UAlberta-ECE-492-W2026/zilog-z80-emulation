`timescale 1ns/1ps
`include "uop.sv"

module controller_next_state (
                              output     uop next_state,
                              input      uop current_state,
                              input wire reset_sig
);

    always_comb begin: next_state_block
        next_state = invalid_uop;
        if (reset_sig) next_state = reset_uop;
    end;


endmodule; // controller_next_state
