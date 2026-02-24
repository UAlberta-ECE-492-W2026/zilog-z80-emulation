`timescale 1ns/1ps
`include "uop.sv"
`include "reg_name.sv"

module decode #(

) (
    input wire [31:0] input_op,
    output uop output_op,
    output reg_name reg_a,
    output reg_name reg_b,
    output wire [7:0] imm_0,
    output wire [15:0] imm_1,
    output wire use_16b_alu,
    output wire [6:0] update_flags
);
    
endmodule
