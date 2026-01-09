`timescale 1ns/1ps

task display_input_output_expected(input reg [7:0] a, b, reg [3:0] opcode, reg [7:0] dout, expected);
   $write("8'h%h | 8'h%h | 4'h%h | 8'h%h | 8'h%h", a, b, opcode, dout, expected);
endtask // display_input_output_expected


module alu_8_tb();

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

   test_vector testvectors[];

   initial begin: file_setup
      $dumpfile("out/sim/alu_8_tb.vcd");
      $dumpvars();
   end

   initial begin: test_definition
      testvectors = new [23];
      // a, b, opcode, expected output
      testvectors[0] = '{7, 7, 0, 14};
      testvectors[1] = '{7, 7, 1, 0};
      testvectors[2] = '{'hD, 7, 2, 5};
      // testing OR
      testvectors[3] = '{'b11001011, 8'b00101011, 3, 8'b11101011};
      //  testing XOR
      testvectors[4] = '{7, 7, 4, 0};
      testvectors[5] = '{8'hFF, 8'b10001010, 4, 8'b01110101};
      // testing sll
      testvectors[6] = '{8'b00000111, 3, 6, 8'b00111000};
      testvectors[7] = '{8'b00001111, 6, 6, 8'b11000000};
      testvectors[8] = '{8'b00001111, 9, 6, 8'b00000000};
      // testing srl
      testvectors[9] = '{8'b11001010, 3, 7, 8'b00011001};
      testvectors[10] = '{8'b11001010, 8, 7, 0};
      // testing sla
      testvectors[11] = '{8'b00000111, 3, 8, 8'b00111000};
      testvectors[12] = '{8'b00001111, 6, 8, 8'b11000000};
      testvectors[13] = '{8'b00001111, 9, 8, 8'b00000000};

      // testing sra
      testvectors[14] = '{8'b11001010, 3, 4'b1001, 8'b11111001};
      testvectors[15] = '{8'b01001010, 3, 4'b1001, 8'b00001001};
      testvectors[16] = '{8'b11001010, 8, 4'b1001, 8'hFF};
      testvectors[17] = '{8'b01001010, 8, 4'b1001, 8'h00};

      // testing rotate
      testvectors[18] = '{8'b11001010, 3, 4'b1010, 8'b01010110};
      testvectors[19] = '{8'b10000000, 10, 4'b1010, 8'b10};

      // testing set. Currently tied to 0
      testvectors[20] = '{7, 7, 13, 0};
      // testing reset
      testvectors[21] = '{7, 7, 14, 0};
      // testing test. Current output is tied to 0
      testvectors[22] = '{7, 7, 15, 0};
   end


   initial begin
      $display("    a |     b |   op |  dout | expected");
      for (int i = 0; i < $size(testvectors); ++i) begin
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
      if (dout == expected) $display("    | PASS");
      else $display("    | FAIL");
   end

   alu_8 dut(.out(dout), .a(a), .b(b), .opcode(opcode));

endmodule
