`timescale 1ns/1ps

module alu_8_tb();
   reg [7:0] a, b;
   reg [3:0] opcode;
   wire [7:0] dout;

   initial begin
      $dumpfile("out/sim/alu_8_tb.vcd");
      $dumpvars();
   end

   initial begin
        #10000 $finish;
   end


   initial begin
      a = 7;
      b = 7;
      opcode = 0;
      #1 $display(dout);

      #50 opcode = 1;
   end

   alu_8 dut(.out(dout), .a(a), .b(b), .opcode(opcode));

endmodule
