`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_on UNUSEDSignal */
module alu_8_status_tb();

   parameter data_width = 8;
   parameter upper_bit = data_width - 1;

   reg [upper_bit:0] a, b;
   alu_op opcode;
   wire [upper_bit:0] dout;
   reg [upper_bit:0] expected;
   wire [7:0] status_flag;
   wire       enable_alu;


   /* verilator lint_off UNUSEDSignal */
task display_input_output_expected(input reg [upper_bit:0] input_a, input_b, alu_op target_opcode, reg [upper_bit:0] data_out, expected_value, reg [7:0] output_status_flag);
   $write("'h%h | 'h%h | %s | 'h%h | 8'b%b | 8'b%b", input_a, input_b, target_opcode.name, data_out , output_status_flag, expected_value);
endtask // display_input_output_expected


   typedef struct {
      reg [upper_bit:0] a;
      reg[upper_bit:0] b;
      alu_op opcode;
      reg [7:0] expected;
   } test_vector;

   typedef test_vector test_vectors[];

   test_vectors testvectors;

   initial begin: file_setup
      $dumpfile("out/sim/alu_8_status_tb.vcd");
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
      testvectors[0] = '{7, 7, ADD, 8'b0};
      testvectors = push_vector(testvectors, '{1, 8'hff, ADD, 8'b01010001});
      // testing  that the zero flag is not asserted when the result not zero
      testvectors = push_vector(testvectors, '{2, 8'hff, ADD, 8'b00010001});
      testvectors = push_vector(testvectors, '{8'h7f, 8'h7f, ADD, 8'b10010100});
      // SUB
      /* testing subtraction of the same value. Should set zero flag, and
       the negative flag. */
      testvectors = push_vector(testvectors, '{8'h7f, 8'h7f, SUB, 8'b01000010});
      /* testing subtraction of postive and a negative value. Should result in
       a large value. So large that it overflows back to negative. There is a
       borrow out, the negative sign bit, and the subtraction bit is used. */
      testvectors = push_vector(testvectors, '{8'h7f, 8'h80, SUB, 8'b10000111});
      testvectors = push_vector(testvectors, '{8'h7e, 8'h7f, SUB, 8'b10010011});

      // COMPARE
      /* Comparison match test. The zero flag is 1 */
      testvectors = push_vector(testvectors, '{7, 7, COMPARE, 8'b01000010});
      /* Comparison miss test. The zero flag is 0 */
      testvectors = push_vector(testvectors, '{7, 8, COMPARE, 8'b10010011});

      // Shift test
      testvectors = push_vector(testvectors, '{8'h2, 0, SLL, 8'b00000000});
      testvectors = push_vector(testvectors, '{8'h3, 0, SLL, 8'b00000100});
      testvectors = push_vector(testvectors, '{8'h83, 1, SLL, 8'b00000101});
      testvectors = push_vector(testvectors, '{8'h2, 0, SLA, 8'b00000000});
      testvectors = push_vector(testvectors, '{8'h3, 0, SLA, 8'b00000100});
      testvectors = push_vector(testvectors, '{8'h81, 1, SLA, 8'b00000001});
      testvectors = push_vector(testvectors, '{8'h2, 0, SRL, 8'b00000000});
      testvectors = push_vector(testvectors, '{8'h3, 0, SRL, 8'b00000100});
      testvectors = push_vector(testvectors, '{8'h83, 1, SRL, 8'b00000101});
      testvectors = push_vector(testvectors, '{8'h2, 0, SRA, 8'b00000000});
      testvectors = push_vector(testvectors, '{8'h3, 0, SRA, 8'b00000100});
      testvectors = push_vector(testvectors, '{8'h81, 1, SRA, 8'b00000101});

      // Logical operations
      testvectors = push_vector(testvectors, '{8'h81, 1, AND, 8'b00000000});
      testvectors = push_vector(testvectors, '{8'h81, 1, OR, 8'b10000000});
      testvectors = push_vector(testvectors, '{8'h81, 1, XOR, 8'b10000000});
   end


   initial begin
      $display("    a |     b |   op |  dout | real status | expected status |");
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
      if (status_flag == expected) $display("    | PASS");
      else $display("    | FAIL");
   end

   alu #(.alu_width(data_width)) dut(
                                     .out(dout),
                                     .a(a),
                                     .b(b),
                                     .opcode(opcode),
                                     .status_flag(status_flag),
                                     .enable(enable_alu));

endmodule
