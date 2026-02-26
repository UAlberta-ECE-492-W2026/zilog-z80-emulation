`timescale 1ns/1ps
`include "mop.sv"
`include "reg_name.sv"

/* verilator lint_off UNUSEDSignal */
task display_input_output_expected_decode(
        input reg[31:0] input_op, 
        mop output_op, 
        reg_name reg_a, 
        reg_name reg_b, 
        reg[7:0] imm_0, 
        reg[15:0] imm_1, 
        reg use_16b_alu, 
        reg[5:0] update_flags,
        mop expected_output_op, 
        reg_name expected_reg_a, 
        reg_name expected_reg_b, 
        reg[7:0] expected_imm_0, 
        reg[15:0] expected_imm_1, 
        reg expected_use_16b_alu, 
        reg[5:0] expected_update_flags
    );
    $write("32'b%b | %s | %s | %s | 8'h%h | 16'h%h | 1'b%b | 6'b%b\n", input_op, output_op.name, reg_a.name, reg_b.name, imm_0, imm_1, use_16b_alu, update_flags);
    $write(" expected:                           | %s | %s | %s | 8'h%h | 16'h%h | 1'b%b | 6'b%b", expected_output_op.name, expected_reg_a.name, expected_reg_b.name, expected_imm_0, expected_imm_1, expected_use_16b_alu, expected_update_flags);

endtask // display_input_output_expected

/* verilator lint_on UNUSEDSignal */

module decode_tb();
    reg[31:0]   input_op;

   	mop         output_op;
	reg_name    reg_a, reg_b;
   	wire [7:0]  imm_0;
   	wire [15:0] imm_1;
   	wire        use_16b_alu;
    wire [5:0]  update_flags;

   	mop         expected_output_op;
	reg_name    expected_reg_a, expected_reg_b;
   	reg [7:0]  expected_imm_0;
   	reg [15:0] expected_imm_1;
   	reg        expected_use_16b_alu;
    reg [5:0]  expected_update_flags;

   	typedef struct {
        reg[31:0]   input_op;
        mop         expected_output_op;
        reg_name    expected_reg_a;
        reg_name    expected_reg_b;
        reg [7:0]   expected_imm_0;
        reg [15:0]  expected_imm_1;
        reg         expected_use_16b_alu;
        reg [5:0]   expected_update_flags;
   	} test_vector;

   	test_vector testvectors[];

   	initial begin: file_setup
      	$dumpfile("out/sim/decode_tb.vcd");
      	$dumpvars();
   	end

   	initial begin: test_definition
      	testvectors = new [1];
      	// input_op, expected_output_op, expected_a, expected_b, expected_imm_0, expected_imm_1, expected_use_16b_alu, expected_update_flags
      	testvectors[0] = '{32'b01001011000000000000000000000000, LD_R_R, C, E, 0, 0, 0, 0};
   	end


   	initial begin
      	$display(" input op                            |  mop |  reg_a | reg_b |  imm_0 | imm_1 | use_16b_alu | expected_update_flags ");
      	for (int i = 0; i < $size(testvectors); ++i) begin
         	#10;
         	input_op                = testvectors[i].input_op;
            expected_output_op      = testvectors[i].expected_output_op;
            expected_reg_a          = testvectors[i].expected_reg_a;
            expected_reg_b          = testvectors[i].expected_reg_b;
            expected_imm_0          = testvectors[i].expected_imm_0;
            expected_imm_1          = testvectors[i].expected_imm_1;
            expected_use_16b_alu    = testvectors[i].expected_use_16b_alu;
            expected_update_flags   = testvectors[i].expected_update_flags;
         	#1;
      	end

      	#10 $finish;
   	end // initial begin

   	always begin
      	#11 display_input_output_expected_decode(
            input_op, 
            output_op, 
            reg_a, 
            reg_b, 
            imm_0, 
            imm_1, 
            use_16b_alu, 
            update_flags,
            expected_output_op, 
            expected_reg_a, 
            expected_reg_b, 
            expected_imm_0, 
            expected_imm_1, 
            expected_use_16b_alu, 
            expected_update_flags
        );
      	if (
            output_op    == expected_output_op && 
            reg_a        == expected_reg_a &&
            reg_b        == expected_reg_b && 
            imm_0        == expected_imm_0 && 
            imm_1        == expected_imm_1 && 
            use_16b_alu  == expected_use_16b_alu && 
            update_flags == expected_update_flags 
        ) 
        begin
            $display("    | PASS");
        end else begin
            $display("    | FAIL");
        end
   	end

   	decode #() dut(
        .input_op(input_op),
        .enable(1'b1),
        .output_op(output_op),
        .reg_a(reg_a),
        .reg_b(reg_b),
        .imm_0(imm_0),
        .imm_1(imm_1),
        .use_16b_alu(use_16b_alu),
        .update_flags(update_flags)
   	);

endmodule
