`timescale 1ns/1ps
`include "uop.sv"
`include "mop.sv"

/** Module for the controller of the datapath controller architecture.
 */
module controller (output wire [3:0] aluop,
                   output wire       wb_signal,
                   output            uop current_uop, /* debug output */

                   input             mop micro_op,
                   input wire        reset, /* active high reset */
                   input wire        clk
   );
   /* parameters */

   /* callables */

   /* declaration ***********************************************************/
   uop current_state;
   uop next_state;
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

        end;
    end;

    /* structural **********************************************************/
    controller_next_state next_state_logic (
                                            .next_state(next_state),
                                            .current_state(current_state),
                                            .reset_sig(reset)
                                            );

    controller_output output_logic(
                                   .wb_sel(wb_signal),
                                   .current_state(current_state)
                                   );
endmodule; // controller
