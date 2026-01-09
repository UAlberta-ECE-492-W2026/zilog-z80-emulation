`timescale 1ns/1ps

//! This module implements the 8-bit ALU that was defined in the Zilog Z80
//! specification
module alu_8
  (output wire [7:0] out,
   input wire [7:0]  a,
   input wire [7:0]  b,
   input wire [4:0]  opcode);


   parameter a_size  = $size(a);
   parameter b_size  = $size(b);

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
   // TODO: Add right rotation
   parameter ROR     = 'b1011;
   parameter INC     = 'b1100;
   parameter DEC     = 'b1101;
   // parameter SET     = 'b1110;
   // parameter RESET   = 'b1111;
   // parameter TEST    = 'b10000;

   wire signed [7:0] signed_a;
   wire signed [7:0] signed_b;
   reg [7:0]         out_var;


   assign signed_a = a;
   assign signed_b = b;
   assign out = out_var;

   always_comb begin
      case (opcode)
        ADD: out_var = a + b;
        SUB: out_var = a - b;
        AND: out_var = a & b;
        OR: out_var = a | b;
        XOR: out_var = a ^ b;
        /* TODO: Check with instruction specification for what type
         of comparison is being done here */
        COMPARE: out_var = 0;
        SLL: out_var = a << b;
        SRL: out_var = a >> b;
        SLA: out_var = a <<< b;
        SRA: out_var = signed_a >>> signed_b;
        /* There is a chance that the following does not synthesize */
        /* TODO: need to make sure that this follows what the instruction
         requires. */
        ROL: out_var = (a << (b % a_size[7:0]))
          | (a >> (a_size - {{(32 - b_size){1'b0}},(b % a_size[7:0])}));
        ROR: out_var = 0;
        INC: out_var = a + 1;
        DEC: out_var = a - 1;
        default: out_var = 0;
        endcase
   end // always_comb


endmodule
