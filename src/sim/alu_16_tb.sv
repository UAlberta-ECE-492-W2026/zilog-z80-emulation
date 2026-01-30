`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_on UNUSEDSignal */
module alu_16_tb();

   parameter data_width = 16;
   parameter upper_bit = data_width -1;

   reg [upper_bit:0] a, b;
   alu_op opcode;
   wire [upper_bit:0] dout;
   reg [upper_bit:0] expected;
   wire [7:0] status_flag;
   wire       enable_alu;


   /* verilator lint_off UNUSEDSignal */
task display_input_output_expected(input reg [upper_bit:0] input_a, input_b, alu_op target_opcode, reg [upper_bit:0] data_out, expected_value, reg [7:0] output_status_flag);
   $write("'h%h | 'h%h | %s | 'h%h | 'h%h | 8'b%b", input_a, input_b, target_opcode.name, data_out, expected_value, output_status_flag);
endtask // display_input_output_expected


   typedef struct {
      reg [upper_bit:0] a;
      reg[upper_bit:0] b;
      alu_op opcode;
      reg [upper_bit:0] expected;
   } test_vector;

   typedef test_vector test_vectors[];

   test_vectors testvectors;

   initial begin: file_setup
      $dumpfile("out/sim/alu_16_tb.vcd");
      $dumpvars();
   end


   function automatic test_vectors push_vector (test_vectors v, test_vector test);
	  test_vectors ret_array = new [v.size() + 1] (v);
      ret_array[v.size()] = test;
      return ret_array;
   endfunction // push_vector

   assign enable_alu = 1;


   /* This is the operations that must be supported in 16 bits mode. The
    * instructions that must be supported are the following:
    *   ADD
    *   ADC
    *   SBC
    *   INC
    *   DEC
    *
    * Therefore, those will be the only operations that are tested in this
    * testbench
     */
   initial begin: test_definition
      testvectors = new [1];
      // a, b, opcode, expected output
      // Add
      testvectors[0] = '{7, 7, ADD, 14};
      testvectors = push_vector(testvectors, '{16'habcd, 16'h0101, ADD, 16'hacce});
      // SUB
      testvectors = push_vector(testvectors, '{16'habcd, 16'h0101, SUB, 16'haacc});
      testvectors = push_vector(testvectors, '{16'habcd, 16'habcd, SUB, 16'h0});
      testvectors = push_vector(testvectors, '{16'habcd, 16'habce, SUB, 16'hffff});
      testvectors = push_vector(testvectors, '{16'habcd, 16'habcc, SUB, 16'h1});


      // INC
      testvectors = push_vector(testvectors, '{16'habcd, 16'h0101, INC, 16'habce});
      testvectors = push_vector(testvectors, '{16'hffff, 16'h0101, INC, 16'h0000});

      // DEC
      testvectors = push_vector(testvectors, '{16'habcd, 16'h0101, DEC, 16'habcc});
      testvectors = push_vector(testvectors, '{16'h0000, 16'h0101, DEC, 16'hffff});

   end


   initial begin
      $display("    a |     b |   op |  dout | expected dout | status flag |");
      for (int i = 0; i < testvectors.size(); ++i) begin
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
      #11 display_input_output_expected(a, b, opcode, dout, expected, status_flag);
      if (dout == expected) $display("    | PASS");
      else $display("    | FAIL");
   end

   alu #(.alu_width(16)) dut(.out(dout), .a(a), .b(b), .opcode(opcode), .status_flag(status_flag), .enable(enable_alu));

endmodule
