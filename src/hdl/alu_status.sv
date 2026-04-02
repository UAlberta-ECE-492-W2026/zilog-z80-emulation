`timescale 1ns/1ps
`include "alu_op.sv"

//! This module implements the status output for the ALU, as defined by the
//! Zilog Z80 specification
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
module  alu_status #(
	parameter integer alu_width=8
)(
	output wire                c,
    output wire                n,
    output wire                pv,
    output wire                h,
    output wire                s,
    output wire                z,
    input wire [alu_width-1:0] a,
    input wire [alu_width-1:0] b,
    input wire [alu_width-1:0] op_result,
    input wire [alu_width:0]   result_buffer,
    input alu_status_op opcode,
   	// op_sign == 1 : negative
   	// op_sign == 0 : positive
   	input wire                 op_sign,
	/* verilator lint_off UNUSEDSIGNAL */
	input wire[5:0]			   flags_in
	/* verilator lint_on UNUSEDSIGNAL */
);
   	localparam integer upper_bit = alu_width - 1;

   	/* function that does overflow_check bit logic */
	/* verilator lint_off UNUSEDSIGNAL */
   	function reg overflow_check(reg sign_bit, first_op, second_op, result);
      	return (sign_bit == 0)
          ? (first_op & second_op & !result)
            | (!first_op & !second_op & result)
              : (first_op & !second_op & !result)
                | (!first_op & second_op & result);
   	endfunction // overflow_check
	/* verilator lint_on UNUSEDSIGNAL */

	/* verilator lint_off UNUSEDSIGNAL */
   	reg[4:0] half_buffer;
	/* verilator lint_on UNUSEDSIGNAL */
   	reg c_var;
   	reg pv_var;
	reg h_var;
   	reg s_var;
   	reg z_var;
    reg      n_var;
    reg [7:0] bcd_acc;
    wire     uppermost_buffer_bit;
    wire     lowest_buffer_bit;

   	assign z = z_var; // bit is very multi-functional
   	assign c = c_var;
   	assign n = n_var;
   	assign pv = pv_var;
   	assign h = (opcode == NUMERIC_OP) ? half_buffer[4] : h_var;
   	assign s = s_var;

    assign uppermost_buffer_bit = result_buffer[alu_width];
    assign lowest_buffer_bit = result_buffer[0];
	integer i;

   	always_comb begin
      	c_var = 0;
      	pv_var = 0;
      	half_buffer = 0;
		h_var = 0;
      	s_var = 0;
      	z_var = 0;
        n_var = 0;
		bcd_acc = 0;


      	case (opcode)
        	NUMERIC_OP: begin
                n_var = op_sign;
           		c_var = uppermost_buffer_bit;
           		pv_var = overflow_check(op_sign,
                                            a[upper_bit],
                                            b[upper_bit],
                                            op_result[upper_bit]);
           		s_var = op_result[upper_bit];
           		z_var = (op_result == 0? 1 : 0);
           		if (op_sign == 1) begin
              		half_buffer = a[3:0] - b[3:0];
				end else begin
             		half_buffer = a[3:0] + b[3:0];
				end
        	end
        	SHIFT_OP: begin
          		pv_var = ~(^op_result); // this is a parity check
                c_var = (op_sign == 0) ? uppermost_buffer_bit
                       : lowest_buffer_bit;
				z_var  = (op_result[7:0] == 8'h00);
				s_var  = op_result[7];
			end
            ROTATE_OP: begin
				// Carry from bit 7 for RL -> bit 0 for RR.
                c_var  = (op_sign == 0) ? result_buffer[8] : result_buffer[0];
                pv_var = ~(^op_result[7:0]);
                s_var  = op_result[7];
                z_var  = (op_result[7:0] == 8'h00);
            end
            BCD_ROTATE_OP: begin
                // updated A = upper byte of packed result
                bcd_acc = 8'(op_result >> 8); 
                // flags updated A only
                pv_var = ~(^bcd_acc);
                s_var  = bcd_acc[7];
                z_var  = (bcd_acc == 8'h00);
                n_var  = 0;
            end
			AND_OP: begin
           		s_var = op_result[upper_bit];
           		z_var = (op_result == 0? 1 : 0);
				h_var = 1;
				// spec says "P/V is set if overflow; otherwise, it is reset." makes no sense imo
				pv_var = overflow_check(op_sign,
                                            a[upper_bit],
                                            b[upper_bit],
                                            op_result[upper_bit]);
				n_var = 0;
				c_var = 0;
			end
			OR_OP: begin
           		s_var = op_result[upper_bit];
           		z_var = (op_result == 0? 1 : 0);
				//h_var = 0; h already set to 0 by default
				// spec says "P/V is set if overflow; otherwise, it is reset." makes no sense imo
				pv_var = overflow_check(op_sign,
                                            a[upper_bit],
                                            b[upper_bit],
                                            op_result[upper_bit]);
				n_var = 0;
				c_var = 0;
			end
			XOR_OP: begin
           		s_var = op_result[upper_bit];
           		z_var = (op_result == 0? 1 : 0);
				//h_var = 0; h already set to 0 by default
				// pv set to if parity is even
				pv_var = 1;
				for (i = 0; i < alu_width; i = i + 1) begin
					pv_var = pv_var ^ op_result[i];
				end
				n_var = 0;
				c_var = 0;
			end
			DAA_OP: begin
				c_var = (flags_in[0] || a > 'h99) ? 1 : 0;
				if (flags_in[1] && ~flags_in[3]) begin
					h_var = 0;
				end else begin
					if (flags_in[1] && flags_in[3]) begin
						h_var = (a & 'hF) < 'h6;
					end else begin
						h_var = (a & 'hF) >= 'hA;
					end
				end
				s_var = op_result[7];
				z_var = (op_result == 0? 1 : 0);
				pv_var = 1;
				for (i = 0; i < alu_width; i = i + 1) begin
					pv_var = pv_var ^ op_result[i];
				end
			end
			CPL_OP: begin
				h_var = 1;
				n_var = 1;
			end
        	default: begin
           	end
        endcase
   	end // always_comb

endmodule
