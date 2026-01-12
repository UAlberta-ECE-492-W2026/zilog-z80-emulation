`timescale 1ns/1ps

//! This module implements the 8-bit ALU that was defined in the Zilog Z80
//! specification
//! Symbol Field Name
//! C Carry Flag
//! N Add/Subtract
//! P/V Parity/Overflow Flag
//! H Half Carry Flag
//! Z Zero Flag
//! S Sign Flag
//! X Not Used
//! status flag field
//! 7: s 6: z 5: x 4: h 3: x 2: p/v 1: n 0: c
module alu_8
  (output wire [7:0] out,
   output wire [7:0] status_flag,
   input wire [7:0]  a,
   input wire [7:0]  b,
   input wire [4:0]  opcode);

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

   wire signed [7:0] signed_a;
   wire signed [7:0] signed_b;
   reg [7:0]         out_var;
   reg               c_var;


   assign status_flag[0] = c_var;
   assign status_flag[7:1] = 0;

   assign signed_a = a;
   assign signed_b = b;
   assign out = out_var;


   always_comb begin
      c_var = 0;
      case (opcode)
        ADD: out_var = a + b;
        SUB: out_var = a - b;
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
        SLL: out_var = a << b;
        SRL: out_var = a >> b;
        SLA: out_var = a <<< b;
        SRA: out_var = signed_a >>> signed_b;
        /* There is a chance that the following does not synthesize */
        ROL: out_var = (a << (b % a_size[7:0]))
          | (a >> (a_size - {{(32 - b_size){1'b0}},(b % a_size[7:0])}));
        ROR: out_var = (a >> (b % a_size[7:0]))
          | (a << (a_size - {{(32 - b_size){1'b0}},(b % a_size[7:0])}));
        INC: out_var = a + 1;
        DEC: out_var = a - 1;
        default: out_var = 0;
        endcase
   end // always_comb


endmodule
