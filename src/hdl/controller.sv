`timescale 1ns/1ps
`include "mop.sv"

/** Module for the controller of the datapath controller architecture.
 */
module controller (c_to_dp_intf.controller intf);
    import uop::*;
    /* parameters */

    /* callables */

    /* declaration ***********************************************************/
    mop current_mop;
    uop::uop_t current_state;


    /* dataflow **************************************************************/

    assign intf.current_state = current_state;

    /* behavioural ***********************************************************/


    /* state driver */
    always_ff @(posedge intf.clk) begin: flip_flop_driver_block
        /* synchronous resets are more reliable, and reduces the chance of
         metastability. */
        if (intf.reset) current_state <= uop::reset;
        else begin
            /* we are not doing a reset */
            current_state <= intf.next_state;
            /* TODO: Verify the correctness of this assignment */
            current_mop <= intf.latch_mop() ? intf.mop_out : current_mop;
        end;
    end;

    /* structural **********************************************************/

endmodule; // controller
