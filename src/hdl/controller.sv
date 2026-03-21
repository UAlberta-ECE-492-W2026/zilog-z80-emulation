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
    uop::uop_t next_state;
    reg [3:0] aluop_reg;


   /* instantiation *********************************************************/
   /* for submodule instantiation */

   /* dataflow **************************************************************/

   assign aluop = aluop_reg;

   /* behavioural ***********************************************************/


    /* state driver */
    always_ff @(posedge clk) begin: flip_flop_driver_block
        /* synchronous resets are more reliable, and reduces the chance of
         metastability. */
        if (reset) current_state <= RESET_STATE;
        else begin
            /* we are not doing a reset */
            current_state <= next_state;
            /* TODO: Verify the correctness of this assignment */
            current_mop = internal_bus.latch_mop() ? internal_bus.out_mop : current_mop;
        end;
    end;

    /* structural **********************************************************/
    controller_next_state next_state_logic (
                                            .ctrl_intf(intf),
                                            .reset_sig(reset)
                                            );

    controller_output output_logic(
                                   .ctrl_intf(intf)
                                   );
endmodule; // controller
