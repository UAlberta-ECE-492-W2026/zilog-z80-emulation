`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_off UNUSEDSignal */
task display_input_output_expected(input reg en, reg [7:0] a, b, alu_op opcode, reg [7:0] dout, expected, reg [7:0] status_flag);
    $write("1'h%h | 8'h%h | 8'h%h | %s | 8'h%h | 8'h%h | 8'b%b", en, a, b, opcode.name, dout, expected, status_flag);
endtask // display_input_output_expected

/* verilator lint_on UNUSEDSignal */
module alu_8_tb();

	reg en;
	reg [7:0] a, b;
   	alu_op opcode;
   	wire [7:0] dout;
   	reg [7:0] expected;
   	wire [7:0] status_flag;

   	typedef struct {
     	reg en;
      	reg [7:0] a;
      	reg[7:0] b;
      	alu_op opcode;
      	reg [7:0] expected;
   	} test_vector;

   	test_vector testvectors[];

   	initial begin: file_setup
      	$dumpfile("out/sim/alu_8_tb.vcd");
      	$dumpvars();
   	end

   	initial begin: test_definition
      	testvectors = new [22];
      	// enable, a, b, opcode, expected output
      	testvectors[0] = '{1, 7, 7, ADD, 14};
      	testvectors[1] = '{1, 7, 7, SUB, 0};
      	testvectors[2] = '{1, 'hD, 7, AND, 5};
      	// testing OR
      	testvectors[3] = '{1, 'b11001011, 8'b00101011, OR, 8'b11101011};
      	//  testing XOR
      	testvectors[4] = '{1, 7, 7, XOR, 0};
      	testvectors[5] = '{1, 8'hFF, 8'b10001010, XOR, 8'b01110101};
      	// testing sll
      	testvectors[6] = '{1, 8'b00000111, 3, SLL, 8'b00111000};
      	testvectors[7] = '{1, 8'b00001111, 6, SLL, 8'b11000000};
      	testvectors[8] = '{1, 8'b00001111, 9, SLL, 8'b00000000};
      	// testing srl
      	testvectors[9] = '{1, 8'b11001010, 3, SRL, 8'b00011001};
      	testvectors[10] = '{1, 8'b11001010, 8, SRL, 0};
      	// testing sla
      	testvectors[11] = '{1, 8'b00000111, 3, SLA, 8'b00111000};
      	testvectors[12] = '{1, 8'b00001111, 6, SLA, 8'b11000000};
      	testvectors[13] = '{1, 8'b00001111, 9, SLA, 8'b00000000};

      	// testing sra
      	testvectors[14] = '{1, 8'b11001010, 3, SRA, 8'b11111001};
      	testvectors[15] = '{1, 8'b01001010, 3, SRA, 8'b00001001};
      	testvectors[16] = '{1, 8'b11001010, 8, SRA, 8'hFF};
      	testvectors[17] = '{1, 8'b01001010, 8, SRA, 8'h00};

      	// testing rotate left
      	testvectors[18] = '{1, 8'b11001010, 3, ROL, 8'b01010110};
      	testvectors[19] = '{1, 8'b10000000, 10, ROL, 8'b10};

      	// testing rotate right
      	testvectors[20] = '{1, 8'b11001010, 3, ROR, 8'b01011001};
      	testvectors[21] = '{1, 8'b10000000, 10, ROR, 8'b00100000};

      	// testing inc

      	// testing set. Currently tied to 0
      	//testvectors[22] = '{1, 7, 7, SET, 0};
     	 // testing reset
     	 //testvectors[23] = '{1, 7, 7, RESET, 0};
     	 // testing test. Current output is tied to 0
     	 //testvectors[24] = '{1, 7, 7, TEST, 0};

      	// testing for parity checking on logical shift left
      	testvectors[33] = '{1, 8'h2, 0, SLL, 2};
      	testvectors[34] = '{1, 8'h3, 0, SLL, 3};

   	end


   	initial begin
      	$display("en|    a |     b |   op |  dout | expected dout | status flag |");
      	for (int i = 0; i < $size(testvectors); ++i) begin
         	#10;
         	en = testvectors[i].en;
         	a = testvectors[i].a;
         	b = testvectors[i].b;
         	opcode = testvectors[i].opcode;
         	expected = testvectors[i].expected;
         	#1;
      	end

      	#10 $finish;
   	end // initial begin

   	always begin
      	#11 display_input_output_expected(en, a, b, opcode, dout, expected, status_flag);
      	if (dout == expected) $display("    | PASS");
      	else $display("    | FAIL");
   	end

   	alu #(
      	.alu_width(8)
   	) dut(
      	.out(dout), 
      	.enable(en),
      	.a(a), 
      	.b(b), 
      	.opcode(opcode), 
      	.status_flag(status_flag)
   	);

endmodule
