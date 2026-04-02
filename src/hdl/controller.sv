`timescale 1ns/1ps

/** After a lot of refactoring bascially all the functionality from here
 has been moved to z80_top, controller_output, and controller_next_state.
 */
module controller (c_to_dp_intf.controller intf);
    always_ff @(posedge intf.clk) begin: flip_flop_driver_block
        if (intf.reset) intf.current_state <= uop::reset;
        else intf.current_state <= intf.next_state;
    end;

endmodule; // controller
