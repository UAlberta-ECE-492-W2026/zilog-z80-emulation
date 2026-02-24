`timescale 1ns/1ps

/** Module for the controller of the datapath controller architecture.
 */
module controller (output wire [3:0] aluop,

                   input wire [3:0]  uop,
                   input wire        reset, /* active high reset */
                   input wire        clk
   );
   /* parameters */

   /* callables */

   /* declaration */
   typedef enum {RESET} controller_states;


   /* instantiation */
   controller_states current_state;
   controller_states next_state;
   reg [3:0] aluop_reg;

   /* dataflow */

   assign aluop = aluop_reg;


   /* behavioural */

   /* next state logic */

   always_comb begin: next_state_block
      next_state = RESET;
      if (reset) next_state = RESET;
   end;

   /* output logic */

   always_comb begin: output_block
      aluop_reg = 0;
      if (reset) aluop_reg = 0;
   end;

   /* state driver */
   always_ff @(posedge clk, reset) begin: flip_flop_driver_block
      if (reset) current_state <= RESET;
      else begin
         /* we are not doing a reset */
         current_state <= next_state;

      end;
   end;
   endmodule
