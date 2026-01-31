`timescale 1ns/1ps

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
   	input wire                 uppermost_out_bit,
   	input wire [3:0]           opcode,
   	// op_sign == 1 : negative
   	// op_sign == 0 : positive
   	input wire                 op_sign);

   	parameter upper_bit=alu_width-1;

   	/* the following are the opcodes for the ALU status system */
   	parameter NUMERIC_OP = 'b0000;
   	parameter SHIFT_OP = 'b1;
   parameter COMPARE_OP = 'b10;



   	/* function that does overflow_check bit logic */
   	function reg overflow_check(reg first_op, second_op, result);
      	return (first_op & second_op & !result)
        | 	(!first_op & !second_op & result);
   	endfunction // overflow_check

   	/* verilator lint_off UNUSEDSIGNAL */
   	reg[4:0] half_buffer;
   	reg c_var;
   	reg pv_var;
   	reg s_var;
   	reg z_var;

   	assign z = z_var; // bit is very multi-functional
   	assign c = c_var;
   	assign n = op_sign;
   	assign pv = pv_var;
   	assign h = half_buffer[4];
   	assign s = s_var;

   	always_comb begin
      	c_var = 0;
      	pv_var = 0;
      	half_buffer = 0;
      	s_var = 0;
      	z_var = 0;

      	case (opcode)
        	NUMERIC_OP: begin
           		c_var = uppermost_out_bit;
           		pv_var = overflow_check(a[upper_bit], b[upper_bit], op_result[upper_bit]);
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
			end
          /* During compare instructions, the zero flag is set if the value in
           the accumulator is equal to the value in the memory stored in the
           address pointed to by register HL. If not equal, then the zero flag
           is cleared. */
          COMPARE_OP: begin
             z_var = a == b ? 1 : 0;
            end
        	default: begin
           	end
        endcase
   	end // always_comb

endmodule
