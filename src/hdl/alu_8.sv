`timescale 1ns/1ps

//! This module implements the 8-bit ALU that was defined in the Zilog Z80
//! specification
module alu_8
  (output wire [7:0] out,
   input wire [7:0]  a,
   input wire [7:0]  b,
   input wire [3:0]  opcode);


   parameter a_size = $size(a);
   parameter b_size = $size(b);

   parameter ADD     = 4'b0000;
   parameter SUB     = 4'b0001;
   parameter AND     = 4'b0010;
   parameter OR      = 4'b0011;
   parameter XOR     = 4'b0100;
   parameter COMPARE = 4'b0101;
   parameter SLL     = 4'b0110;
   parameter SRL     = 4'b0111;
   parameter SLA     = 4'b1000;
   parameter SRA     = 4'b1001;
   parameter ROR     = 4'b1010;
   // TODO: Add right rotation
   parameter INC     = 4'b1011;
   parameter DEC     = 4'b1100;
   // parameter SET     = 4'b1101;
   // parameter RESET   = 4'b1110;
   // parameter TEST    = 4'b1111;

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
        ROR: out_var = (a << (b % a_size[7:0]))
          | (a >> (a_size - {{(32 - b_size){1'b0}},(b % a_size[7:0])}));
        INC: out_var = a + 1;
        DEC: out_var = a - 1;
        default: out_var = 0;
        endcase
   end // always_comb


endmodule
