`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_off UNUSEDSignal */
task display_input_output_expected(
    input reg en,
    input reg carry_in,
    input reg [7:0] a,
    input reg [7:0] b,
    input alu_op opcode,
    input reg [7:0] dout,
    input reg [7:0] expected,
    input reg [5:0] status_flag
);
    $write("1'h%h | 8'h%h | 8'h%h | %s | 8'h%h | 8'h%h | 8'b%b", en, a, b, opcode.name, dout, expected, status_flag);
endtask // display_input_output_expected

/* verilator lint_on UNUSEDSignal */
module alu_8_tb();

	reg en;
	reg [7:0] a, b;
   	alu_op opcode;
   	wire [7:0] dout;
   	reg [7:0] expected;
   	wire [5:0] status_flag;
	reg carry_in;

   	typedef struct {
     	reg en;
      	reg [7:0] a;
      	reg[7:0] b;
      	alu_op opcode;
      	reg [7:0] expected;
		reg carry_in;
   	} test_vector;

   	test_vector testvectors[];

   	initial begin: file_setup
      	$dumpfile("out/sim/alu_8_tb.vcd");
      	$dumpvars();
   	end

   	initial begin: test_definition
      	testvectors = new [25];
      	// enable, a, b, opcode, expected output
      	testvectors[0]  = '{1, 8'd7, 8'd7, ALU_ADD,    8'd14,       0};
        testvectors[1]  = '{1, 8'd7, 8'd7, ALU_SUB,    8'd0, 0};
        testvectors[2]  = '{1, 8'h0D,       8'd7, ALU_AND,    8'd5, 0};

        // OR
        testvectors[3]  = '{1, 8'b11001011, 8'b00101011, ALU_OR,     8'b11101011, 0};

        // XOR
        testvectors[4]  = '{1, 8'd7, 8'd7, ALU_XOR,    8'd0, 0};
        testvectors[5]  = '{1, 8'hFF,       8'b10001010, ALU_XOR,    8'b01110101, 0};

        // SLL
        testvectors[6]  = '{1, 8'b00000111, 8'd3, ALU_SLL, 8'b00111000, 0};
        testvectors[7]  = '{1, 8'b00001111, 8'd6, ALU_SLL, 8'b11000000, 0};
        testvectors[8]  = '{1, 8'b00001111, 8'd9, ALU_SLL, 8'b00000000, 0};

        // SRL
        testvectors[9]  = '{1, 8'b11001010, 8'd3, ALU_SRL, 8'b00011001, 0};
        testvectors[10] = '{1, 8'b11001010, 8'd8, ALU_SRL, 8'h00,       0};

        // SLA
        testvectors[11] = '{1, 8'b00000111, 8'd3, ALU_SLA, 8'b00111000, 0};
        testvectors[12] = '{1, 8'b00001111, 8'd6, ALU_SLA, 8'b11000000, 0};
        testvectors[13] = '{1, 8'b00001111, 8'd9, ALU_SLA, 8'b00000000, 0};

        // SRA
        testvectors[14] = '{1, 8'b11001010, 8'd3, ALU_SRA, 8'b11111001, 0};
        testvectors[15] = '{1, 8'b01001010, 8'd3, ALU_SRA, 8'b00001001, 0};
        testvectors[16] = '{1, 8'b11001010, 8'd8, ALU_SRA, 8'hFF, 0};
        testvectors[17] = '{1, 8'b01001010, 8'd8, ALU_SRA, 8'h00, 0};

        // ROL
        testvectors[18] = '{1, 8'b11001010, 8'd3, ALU_ROL, 8'b01010110, 0};
        testvectors[19] = '{1, 8'b10000000, 8'd10, ALU_ROL, 8'b00000010, 0};

        // ROR
        testvectors[20] = '{1, 8'b11001010, 8'd3, ALU_ROR, 8'b01011001, 0};
        testvectors[21] = '{1, 8'b10000000, 8'd10, ALU_ROR, 8'b00100000, 0};

      	// testing inc

      	// testing set. Currently tied to 0
      	//testvectors[22] = '{1, 7, 7, SET, 0};
     	 // testing reset
     	 //testvectors[23] = '{1, 7, 7, RESET, 0};
     	 // testing test. Current output is tied to 0
     	 //testvectors[24] = '{1, 7, 7, TEST, 0};

      	// testing for parity checking on logical shift left
		// testvectors[33] = '{1, 8'h2, 0, SLL, 2};
		// testvectors[34] = '{1, 8'h3, 0, SLL, 3};	

	    // adc
        testvectors[22] = '{1, 8'h01, 8'h02, ALU_ADC, 8'h03, 0};
        testvectors[23] = '{1, 8'h0F, 8'h00, ALU_ADC, 8'h10, 1};

        // sbc
        testvectors[24] = '{1, 8'h05, 8'h02, ALU_SBC, 8'h03, 0};
        testvectors[25] = '{1, 8'h10, 8'h00, ALU_SBC, 8'h0F, 1};

   	end


   	initial begin
      	$display("en| cin  |   a |     b |   op |  dout | expected dout | status flag |");
      	for (int i = 0; i < $size(testvectors); ++i) begin
         	#10;
         	en = testvectors[i].en;
			carry_in = testvectors[i].carry_in;
         	a = testvectors[i].a;
         	b = testvectors[i].b;
         	opcode = testvectors[i].opcode;
         	expected = testvectors[i].expected;
         	#1;
      	end

      	#10 $finish;
   	end // initial begin

   	always begin
      	#11 display_input_output_expected(en, carry_in, a, b, opcode, dout, expected, status_flag);
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
      	.status_flag(status_flag),
		.carry_in(carry_in)
   	);

endmodule
