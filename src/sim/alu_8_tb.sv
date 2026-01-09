`timescale 1ns/1ps

task display_input_output_expected(input reg [7:0] a, b, reg [3:0] opcode, reg [7:0] dout, expected);
   $write("8'h%h | 8'h%h | 4'h%h | 8'h%h | 8'h%h", a, b, opcode, dout, expected);
endtask // display_input_output_expected


module alu_8_tb();
   parameter number_of_tests = 16;

   reg [7:0] a, b;
   reg [3:0] opcode;
   wire [7:0] dout;
   reg [7:0] expected;

   typedef struct {
      reg [7:0] a;
      reg[7:0] b;
      reg [3:0] opcode;
      reg [7:0] expected;
   } test_vector;

   test_vector testvectors[number_of_tests];

   initial begin: file_setup
      $dumpfile("out/sim/alu_8_tb.vcd");
      $dumpvars();
   end

   initial begin: test_definition
      // a, b, opcode, expected output
      testvectors[0] = '{7, 7, 0, 14};
      testvectors[1] = '{7, 7, 1, 0};
      testvectors[2] = '{'hD, 7, 2, 5};
      testvectors[3] = '{'b11001011, 8'b00101011, 3, 8'b11101011}; // Testing OR operation
      //  testing XOR
      testvectors[4] = '{7, 7, 4, 0};
      testvectors[5] = '{8'hFF, 8'b10001010, 4, 8'b01110101};
      testvectors[6] = '{7, 7, 6, 14};
      testvectors[7] = '{7, 7, 7, 14};
      testvectors[8] = '{7, 7, 8, 14};
      testvectors[9] = '{7, 7, 9, 14};
      testvectors[10] = '{7, 7, 10, 14};
      testvectors[11] = '{7, 7, 11, 14};
      testvectors[12] = '{7, 7, 12, 14};
      testvectors[13] = '{7, 7, 13, 14};
      testvectors[14] = '{7, 7, 14, 14};
      testvectors[15] = '{7, 7, 15, 0};
   end


   initial begin
      $display("    a |     b |   op |  dout | expected");
      for (int i = 0; i < number_of_tests; ++i) begin
         #10;
         a = testvectors[i].a;
         b = testvectors[i].b;
         opcode = testvectors[i].opcode;
         expected = testvectors[i].expected;
         #1;
      end

      #10 $finish;
   end // initial begin

   always begin
      #11 display_input_output_expected(a, b, opcode, dout, expected);
      if (dout == expected) $display(" | PASS");
      else $display(" | FAIL");
   end

   alu_8 dut(.out(dout), .a(a), .b(b), .opcode(opcode));

endmodule
