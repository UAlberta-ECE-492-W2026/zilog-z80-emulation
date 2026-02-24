`timescale 1ns/1ps
`include "uop.sv"

/** Module for the controller of the datapath controller architecture.
 */
module controller (output wire [3:0] aluop,
                   output wire wb_signal,

                   input uop  micro_op,
                   input wire        reset, /* active high reset */
                   input wire        clk
   );
   /* parameters */
   typedef enum {RESET_STATE,
                 FETCH_STATE,
                 DECODE_STATE,
                 EXECUTE_STATE,
                 WRITE_BACK_STATE
                 } controller_states;

   /* callables */

   /* declaration ***********************************************************/
   controller_states current_state;
   controller_states next_state;
   reg [3:0] aluop_reg;
   reg       wb_signal_reg;



   /* instantiation *********************************************************/
   /* for submodule instantiation */

   /* dataflow **************************************************************/

   assign aluop = aluop_reg;
   assign wb_signal = wb_signal_reg;

   /* behavioural ***********************************************************/

   /* next state logic */
   always_comb begin: next_state_block
      next_state = RESET_STATE;
      if (reset) next_state = RESET_STATE;
      else begin
         case (current_state)
           FETCH_STATE: begin
              next_state = DECODE_STATE;
              case (micro_op)
                NOP:
                  next_state = FETCH_STATE;
                default:
                  next_state = DECODE_STATE;
              endcase; // case (micro_op)

           end
           DECODE_STATE: next_state = EXECUTE_STATE;
           EXECUTE_STATE: next_state = WRITE_BACK_STATE;
           WRITE_BACK_STATE: next_state = FETCH_STATE;
           default: begin
              next_state = RESET_STATE; /* system should reset on an unhandled case */
           end
         endcase
      end;
   end;

   /* output logic */
   always_comb begin: output_block
      aluop_reg = 0;
      if (reset) aluop_reg = 0;
      else begin
         case (current_state)
           RESET_STATE: begin
              aluop_reg = 0;
           end
           WRITE_BACK_STATE: wb_signal_reg = 1;
           default: begin
           end
         endcase; // case (current_state)

      end;
   end;

   /* state driver */
   always_ff @(posedge clk, reset) begin: flip_flop_driver_block
      if (reset) current_state <= RESET_STATE;
      else begin
         /* we are not doing a reset */
         current_state <= next_state;

      end;
   end;
   endmodule
