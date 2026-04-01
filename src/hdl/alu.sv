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
    output wire [5:0] status_flag,

    input wire [alu_width-1:0]  a,
    input wire [alu_width-1:0]  b,
    input alu_op opcode,
	input wire enable,
	input wire [5:0] flags_in
);
    parameter upper_bit=alu_width-1;

    reg [upper_bit + 1:0]     tmp; // output value buffer
    reg [upper_bit:0]         out_var;
    wire               c_var; // carry bit variable
    wire               n_var;
    wire               pv_var;
    wire               z_var;
    wire               h_var;
    wire               s_var;
    alu_status_op      status_opcode;
    reg                status_sign;
	reg [upper_bit:0]  status_b;
	reg [7:0]		   acc_rotated;  // updated accumulator RLD/RRD
	reg [7:0]		   mem_rotated;  // updated memory byte RLD/RRD

    wire carry_in;
    assign carry_in = flags_in[0];

	// set outputs to X if not enabled to aid debugging
    assign status_flag[5] = enable ? s_var  : 'Z;
    assign status_flag[4] = enable ? z_var  : 'Z;
    assign status_flag[3] = enable ? h_var  : 'Z;
    assign status_flag[2] = enable ? pv_var : 'Z;
    assign status_flag[1] = enable ? n_var  : 'Z;
    assign status_flag[0] = enable ? c_var  : 'Z;

    assign out = enable ? out_var : '{default: 'Z};

    always_comb begin
        status_opcode = NUMERIC_OP;
		tmp = 0; // default set to 0 to prevent generation of a latch
		status_sign = 0;
		status_b = b;
		out_var = 0;  // stop latch interference
		acc_rotated = 8'h00;
		mem_rotated = 8'h00;

        case (opcode)
        	ALU_ADD: begin
           		tmp = a + b;
           		out_var = tmp[upper_bit:0];
        	end
        	ALU_SUB: begin
           		tmp = a - b;
           		out_var = tmp[upper_bit:0];
           		status_sign = 1;
        	end
            ALU_ADC: begin
                tmp = a + b + carry_in;
                out_var = tmp[upper_bit:0];
                status_b = b + carry_in;
            end
            ALU_SBC: begin
                tmp = a - b - carry_in;
                out_var = tmp[upper_bit:0];
                status_sign = 1;
                status_b = b + carry_in;
            end
        	ALU_COMPARE: begin
               /* The compare operation does not output to accumulator, it
                just affects the status bits. The spec of the Z80 allows the
                COMPARE operation to be implemented as the subtraction op.
                 */
           		tmp = a - b;
           		out_var = tmp[upper_bit:0];
           		status_sign = 1;
			end
        	ALU_AND: begin
           		out_var = a & b;
                status_opcode = AND_OP;
        	end
        	ALU_OR: begin
           		out_var = a | b;
                status_opcode = OR_OP;
        	end
        	ALU_XOR: begin
           		out_var = a ^ b;
                status_opcode = XOR_OP;
        	end
            ALU_RLC: begin
                status_opcode = ROTATE_OP;
                tmp = a << 1;
                out_var = {tmp[alu_width-1:1], tmp[alu_width]};
                status_sign = 0;
            end
            ALU_RL: begin
                status_opcode = ROTATE_OP;
                tmp = a << 1;
                out_var = {tmp[alu_width-1:1], carry_in};
                status_sign = 0;
            end 
            ALU_RRC: begin
                status_opcode = ROTATE_OP;
                tmp = {1'b0, a};
                out_var = {tmp[0], tmp[alu_width-1:1]};
                status_sign = 1;
            end
            ALU_RR: begin
                status_opcode = ROTATE_OP;
                tmp = {1'b0, a};
                out_var = {carry_in, tmp[alu_width-1:1]};
                status_sign = 1;
            end 
            ALU_SLA: begin
                status_opcode = SHIFT_OP;
                tmp = a << 1;
                out_var = tmp[alu_width-1:0];
                status_sign = 0;
            end 
            ALU_SRA: begin
                status_opcode = SHIFT_OP;
                tmp = {1'b0, a};
                out_var = {tmp[alu_width-1], tmp[alu_width-1:1]};
                status_sign = 1;
            end 
            ALU_SRL: begin
                status_opcode = SHIFT_OP;
                tmp = {1'b0, a};
                out_var = {1'b0, tmp[alu_width-1:1]};
                status_sign = 1;
            end

            ALU_RLD: begin
                status_opcode = BCD_ROTATE_OP;
                if (alu_width == 16) begin
                    acc_rotated = {b[7:4], a[7:4]};
                    mem_rotated = {a[3:0], b[3:0]};
                    // packed result: upper byte = new memory byte, lower byte = new A
                    out_var = '0;
                    out_var = ({{(alu_width-8){1'b0}}, mem_rotated} << 8)
                            |  {{(alu_width-8){1'b0}}, acc_rotated};
                    tmp = '0;
                    tmp[upper_bit:0]   = out_var;
                    tmp[upper_bit + 1] = carry_in;
                end
            end
            ALU_RRD: begin
                status_opcode = BCD_ROTATE_OP;
                if (alu_width == 16) begin
                    acc_rotated = {b[7:4], a[3:0]};
                    mem_rotated = {b[3:0], a[7:4]};
                    out_var = ({{(alu_width-8){1'b0}}, mem_rotated} << 8)
                            |  {{(alu_width-8){1'b0}}, acc_rotated};
                    tmp = '0;
                    tmp[upper_bit:0]   = out_var;
                    tmp[upper_bit + 1] = carry_in;
                end
            end
        	//ALU_INC:begin
           	//	tmp = a + 1;
           	//	out_var = tmp[upper_bit:0];
        	//end
        	ALU_DEC: begin
           		tmp = a - 1;
           		out_var = tmp[upper_bit:0];
           		status_sign=1;
        	end
            // https://stackoverflow.com/questions/8119577/z80-daa-instruction
            ALU_DAA: begin
                status_opcode = DAA_OP;
                if ((flags_in[3] || ((a & 'hF) > 'h9)) && (flags_in[0] || (a > 'h99))) begin
                    out_var = a + (flags_in[1] ? 'h9A : 'h66);
                end else if (flags_in[3] || ((a & 'hF) > 'h9)) begin
                    out_var = a + (flags_in[1] ? 'hFA : 'h06);
                end else if (flags_in[0] || (a > 'h99)) begin
                    out_var = a + (flags_in[1] ? 'hA0 : 'h60);
                end
            end
            ALU_CPL: begin
                status_opcode = CPL_OP;
                out_var = ~a;
            end
			ALU_PASS_A: begin
				out_var = a;
			end
			ALU_PASS_B: begin
				out_var = b;
			end
        	default: begin
				out_var = 0;
			end
        endcase
   	end // always_comb

    alu_status #(.alu_width(alu_width))
    status_system (
        .c(c_var),
        .n(n_var),
        .pv(pv_var),
        .h(h_var),
        .s(s_var),
        .z(z_var),
        .a(a),
        .b(status_b),
        .op_result(out_var),
        .result_buffer(tmp),
        .opcode(status_opcode),
        .op_sign(status_sign),
        .flags_in(flags_in)
    );

endmodule
