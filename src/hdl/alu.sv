`timescale 1ns/1ps

//! This module implements the 8-bit ALU that was defined in the Zilog Z80
//! specification
//! Symbol Field Name
//! C Carry Flag
//! N Add/Subtract
//! P/V Parity/Overflow Flag -> signed overflow and parity on shifts and
//!   rotates. 1 for even, 0 for odd
//! H Half Carry Flag
//! Z Zero Flag
//! S Sign Flag
//! X Not Used
//! status flag field
//! 7: s 6: z 5: x 4: h 3: x 2: p/v 1: n 0: c
module  alu
  #(parameter integer alu_width=8)
  (output wire [alu_width-1:0] out,
   output wire [7:0] status_flag,
   input wire [alu_width-1:0]  a,
   input wire [alu_width-1:0]  b,
   input wire [4:0]  opcode);

   parameter upper_bit=alu_width-1;

   parameter a_size  = $size(a);
   parameter b_size  = $size(b);

   /* the following are the opcodes for the ALU */
   parameter ADD     = 'b0000;
   parameter SUB     = 'b0001;
   parameter AND     = 'b0010;
   parameter OR      = 'b0011;
   parameter XOR     = 'b0100;
   parameter COMPARE = 'b0101;
   parameter SLL     = 'b0110;
   parameter SRL     = 'b0111;
   parameter SLA     = 'b1000;
   parameter SRA     = 'b1001;
   parameter ROL     = 'b1010;
   parameter ROR     = 'b1011;
   parameter INC     = 'b1100;
   parameter DEC     = 'b1101;
   // parameter SET     = 'b1110;
   // parameter RESET   = 'b1111;
   // parameter TEST    = 'b10000;

   /* status opcodes */
   parameter NUMERIC = 'b0000;
   parameter SHIFT = 'b1;


   wire signed [upper_bit:0] signed_a;
   wire signed [upper_bit:0] signed_b;
   reg [upper_bit + 1:0]                  tmp; // output value buffer
   reg [upper_bit:0]         out_var;
   reg               c_var; // carry bit variable
   reg               n_var;
   reg               pv_var;
   reg               z_var;
   reg               h_var;
   reg               s_var;
   reg [3:0]         status_opcode;
   reg               status_sign;

   /* function that does parity bit logic */
   function reg parity(reg first_op, second_op, result);
      return (first_op & second_op & !result)
        | (!first_op & !second_op & result);
   endfunction // parity


   assign status_flag[7] = s_var;
   assign status_flag[6] = z_var;
   assign status_flag[5] = 0;
   assign status_flag[4] = h_var;
   assign status_flag[3] = 0;
   assign status_flag[2] = pv_var;
   assign status_flag[1] = n_var;
   assign status_flag[0] = c_var;

   assign signed_a = a;
   assign signed_b = b;
   assign out = out_var;


   always_comb begin
      status_opcode = NUMERIC;
      case (opcode)
        ADD: begin
           tmp = a + b;
           out_var = tmp[upper_bit:0];
        end
        SUB: begin
           tmp = a - b;
           out_var = tmp[upper_bit:0];
           status_sign = 1;
        end
        AND: begin
           out_var = a & b;
        end
        OR: begin
           out_var = a | b;
        end
        XOR: begin
           out_var = a ^ b;
        end
        /* TODO: Check with instruction specification for what type
         of comparison is being done here */
        COMPARE: out_var = 0;
        SLL: begin
           status_opcode = SHIFT;
           out_var = a << b;
        end
        SRL: begin
           status_opcode = SHIFT;
           out_var = a >> b;
        end
        SLA: begin
           status_opcode = SHIFT;
           out_var = a <<< b;
        end
        SRA: begin
           status_opcode = SHIFT;
           out_var = signed_a >>> signed_b;
        end
        /* There is a chance that the following does not synthesize */
        ROL: begin // need to implement the pv flag bit for this
           status_opcode = SHIFT;
           out_var = (a << (b % a_size[upper_bit:0]))
             | (a >> (a_size - {{(32 - b_size){1'b0}},(b % a_size[upper_bit:0])}));
        end
        ROR: begin
           status_opcode = SHIFT;
           out_var = (a >> (b % a_size[upper_bit:0]))
             | (a << (a_size - {{(32 - b_size){1'b0}},(b % a_size[upper_bit:0])}));
        end
        INC:begin
           tmp = a + 1;
           out_var = tmp[upper_bit:0];
        end
        DEC: begin
           tmp = a - 1;
           out_var = tmp[upper_bit:0];
           status_sign=1;
        end
        default: out_var = 0;
        endcase
   end // always_comb

   alu_status #(.alu_width(alu_width))
   status_system (.c(c_var),
                  .n(n_var),
                  .pv(pv_var),
                  .h(h_var),
                  .s(s_var),
                  .z(z_var),
                  .a(a),
                  .b(b),
                  .op_result(out_var),
                  .uppermost_out_bit(tmp[alu_width]),
                  .opcode(status_opcode),
                  .op_sign(status_sign));

endmodule
