`timescale 1ns/1ps

/** Module for the controller of the datapath controller architecture.
 */
module controller (
   input wire [3:0] detected_opcode,
   input wire       resetn, /* active low reset */
   input wire       clk
   );
   /* parameters */

   /* callables */

   /* declaration */
   typedef enum {RESET} controller_states;


   /* instantiation */
   controller_states current_state;

   /* behavioural */

   /* next state logic */

   /* output logic */

   /* state driver */
   always_ff @(posedge clk, resetn) begin
      if (!resetn) current_state <= RESET;
      else begin
      end;
   end;
   endmodule
