`timescale 1ns/1ps
`include "alu_op.sv"

//! This module implements the 8-bit ALU that was defined in the Zilog Z80
//! specification
//! Symbol Field Name
//! C Carry Flag
//! N Add/Subtract
//! P/V Parity/Overflow Flag -> signed overflow and parity on shifts and
//!   rotates. 1 for even, 0 for odd
//! H Half Carry Flag
//! Z Zero Flag
//! S Sign Flag
//! X Not Used
//! status flag field
//! 7: s 6: z 5: x 4: h 3: x 2: p/v 1: n 0: c
module  alu #(
    parameter integer alu_width=8
)(
    output wire [alu_width-1:0] out,
    output wire [7:0] status_flag,

    input wire [alu_width-1:0]  a,
    input wire [alu_width-1:0]  b,
    input alu_op opcode,
	input wire enable
);

    parameter upper_bit=alu_width-1;

    parameter a_size  = $size(a);
    parameter b_size  = $size(b);

    /* status opcodes */
    parameter NUMERIC = 'b0000;
    parameter SHIFT = 'b1;


    wire signed [upper_bit:0] signed_a;
    wire signed [upper_bit:0] signed_b;
    reg [upper_bit + 1:0]     tmp; // output value buffer
    reg [upper_bit:0]         out_var;
    wire               c_var; // carry bit variable
    wire               n_var;
    wire               pv_var;
    wire               z_var;
    wire               h_var;
    wire               s_var;
    reg [3:0]          status_opcode;
    reg                status_sign;

    /* function that does parity bit logic */
    function reg parity(reg first_op, second_op, result);
        return (first_op & second_op & !result)
        | (!first_op & !second_op & result);
    endfunction // parity

	// set outputs to X if not enabled to aid debugging
    assign status_flag[7] = enable ? s_var  : 'X;
    assign status_flag[6] = enable ? z_var  : 'X;
    assign status_flag[5] = 0;
    assign status_flag[4] = enable ? h_var  : 'X;
    assign status_flag[3] = 0;
    assign status_flag[2] = enable ? pv_var : 'X;
    assign status_flag[1] = enable ? n_var  : 'X;
    assign status_flag[0] = enable ? c_var  : 'X;

    assign out = enable ? out_var : '{default: 'X};

	// technically not needed, but should clarify intent when debugging
    assign signed_a = enable ? a : '{default: 'X};
    assign signed_b = enable ? b : '{default: 'X};


    always_comb begin
        status_opcode = NUMERIC;
		tmp = 0; // default set to 0 to prevent generation of a latch
		status_sign = 0; 

        case (opcode)
        	ADD: begin
           		tmp = a + b;
           		out_var = tmp[upper_bit:0];
        	end
        	SUB: begin
           		tmp = a - b;
           		out_var = tmp[upper_bit:0];
           		status_sign = 1;
        	end
        	AND: begin
           		out_var = a & b;
        	end
        	OR: begin
           		out_var = a | b;
        	end
        	XOR: begin
           		out_var = a ^ b;
        	end
        	COMPARE: begin
               /* The compare operation does not output to accumulator, it
                just affects the status bits.
                 */
				out_var = 0;
			end
        	SLL: begin
           		status_opcode = SHIFT;
           		out_var = a << b;
        	end
        	SRL: begin
           		status_opcode = SHIFT;
           		out_var = a >> b;
        	end
        	SLA: begin
           		status_opcode = SHIFT;
           		out_var = a <<< b;
        	end
        	SRA: begin
           		status_opcode = SHIFT;
           		out_var = signed_a >>> signed_b;
        	end
        	/* There is a chance that the following does not synthesize */
        	ROL: begin // need to implement the pv flag bit for this
           		status_opcode = SHIFT;
           		out_var = (a << (b % a_size[upper_bit:0]))
            		| (a >> (a_size - {{(32 - b_size){1'b0}},(b % a_size[upper_bit:0])}));
			end
        	ROR: begin
           		status_opcode = SHIFT;
           		out_var = (a >> (b % a_size[upper_bit:0]))
            		| (a << (a_size - {{(32 - b_size){1'b0}},(b % a_size[upper_bit:0])}));
        	end
        	INC:begin
           		tmp = a + 1;
           		out_var = tmp[upper_bit:0];
        	end
        	DEC: begin
           		tmp = a - 1;
           		out_var = tmp[upper_bit:0];
           		status_sign=1;
        	end
        	default: begin
				out_var = '{default: 'X};
			end
        endcase
   	end // always_comb

   	alu_status #(.alu_width(alu_width))
   	status_system (.c(c_var),
                  .n(n_var),
                  .pv(pv_var),
                  .h(h_var),
                  .s(s_var),
                  .z(z_var),
                  .a(a),
                  .b(b),
                  .op_result(out_var),
                  .uppermost_out_bit(tmp[alu_width]),
                  .opcode(status_opcode),
                  .op_sign(status_sign));

endmodule
