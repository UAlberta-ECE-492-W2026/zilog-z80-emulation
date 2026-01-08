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

      // testing subtraction
      #50 opcode = 1;

      // testing and
      #50 opcode = 2;
      a = 'hD;

      // testing or
      #50 a = 'b11001011;
      b = 8'b00101011;
      opcode = 3;
      
   end

   alu_8 dut(.out(dout), .a(a), .b(b), .opcode(opcode));

endmodule
