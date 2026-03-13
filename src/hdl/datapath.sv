
`timescale 1ns/1ps
`include "alu_op.sv"
`include "mop.sv"
`include "exx_type.sv"
`include "reg_name.sv"
`include "f_op.sv"

`include "alu_wrapper.sv"
`include "register_file.sv"
`include "generic_buffer.sv"

module datapath (
    input wire clk,
    input wire reset,

    // buffers
    input wire ir_en,
    input wire o_buff_en,

    // ALU
    input wire alu_enable,
    input wire alu_16b_mode,
    input alu_op alu_opcode,
    input alu_op update_flags,

    // register file
    input reg_name reg_a_sel,
    input reg_name reg_b_sel,
    input reg_name reg_w_sel,
    input wire reg_w_en,
    input wire f_w_en,
    input f_op f_op,
    input exx_type exx,
    output wire[5:0] f,

    // mux
    input wire [1:0] alu_mux_a_sel,
    input wire [3:0] alu_mux_b_sel,
    input wire o_buff_sel,
    input wire [1:0] write_back_sel,

    // memory interfacing
    input wire [7:0] memory_in,
    input wire [7:0] io_memory_in,
    output wire [15:0] memory_out, // data or address depending on uop

    // instruction decode
    // some of these have corrosponding similarly named inputs from the controller
    output mop mop_out,
    output reg_name reg_a_sel_out,
    output reg_name reg_b_sel_out,
    output wire [7:0] imm_0_out,
    output wire [15:0] imm_1_out,
    output wire use_16b_alu_out,
    output wire [5:0] update_flags_out,  
    output wire [2:0] instuction_length_out,

    // misc
    input wire [15:0] imm_in,
    input wire [2:0] instuction_length
);
    // instruction related
    wire [15:0] ir_mux_out;
    wire [15:0] ir_buff_out;

    // alu and data movement related
    wire [15:0] alu_a;
    wire [15:0] alu_b;
    wire [15:0] reg_a;
    wire [15:0] reg_b;
    wire [15:0] o_buff_out;
    wire [15:0] o_buff_mux_out;
    wire [15:0] alu_out;
    wire [15:0] reg_w_data;

    // flags
    wire [5:0] f_set;
    wire [5:0] f_reset;
    wire [5:0] f_toggle;


    buffer #(16) instruction_buff(
        .in(ir_mux_out),
        .w(ir_en),
        .clk(clk),
        .reset(reset),
        .out(ir_buff_out)
    );


    // instruction related stuff
    decode #() decode (
        .input_op(ir_buff_out),
        .enable(1'b1),
        .output_op(mop_out),
        .reg_a(reg_a_sel_out),
        .reg_b(reg_b_sel_out),
        .imm_0(imm_0_out),
        .imm_1(imm_1_out),
        .use_16b_alu(use_16b_alu_out),
        .update_flags(update_flags_out)//,.instuction_length(instuction_length_out)
    );


    // for CCF and SCF instructions. tempted to put this in the register file
    always_comb begin
        case (f_op)
            CCF: begin
                f_toggle[0] = 1; // main intent of the CCF instruction
                f_reset[1] = 1; // side effect
            end
            SCF: begin
                f_set[0] = 1; // main intent
                f_reset[1] = 1; // wow side effects! amazing
                f_reset[3] = 1;
            end
            default: ;
        endcase
    end


    register_file #() register_file (
        .clk(clk),
        .reset(reset),
        .exx(exx),
        .reg_a_sel(reg_a_sel),
        .reg_b_sel(reg_b_sel),
        .reg_a(reg_a),
        .reg_b(reg_a),
        .reg_w_sel(reg_w_sel),
        .reg_w_data(reg_w_data),
        .reg_w_en(reg_w_en),
        .f_set(f_set),
        .f_reset(f_reset),
        .f_toggle(f_toggle),
        .f_w_en(f_w_en),
        .f(f),
    );


    // op buff mux
    always_comb begin
        case (o_buff_sel)
            1'b0: o_buff_mux_out = reg_a; // TODO: this needs to be thought about
            default: o_buff_mux_out = 16'hXXXX;
        endcase
    end


    // op buff
    buffer #(16) op_buff (
        .in(o_buff_mux_out),
        .w(o_buff_en),
        .clk(clk),
        .reset(reset),
        .out(o_buff_out)
    );


    // alu mux a and mux b
    always_comb begin
        unique case (alu_mux_a_sel)
            2'b00: alu_a = reg_a;
            2'b01: alu_a = o_buff_out;
            default: alu_a = 16'hXXXX;
        endcase

        unique case (alu_mux_b_sel)
            4'b0000: alu_b = reg_b;
            4'b0001: alu_b = imm_in;
            4'b0010: alu_b = {14'b00000000000000, instuction_length};
            4'b0011: alu_b = -2;
            4'b0100: alu_b = -1;
            4'b0101: alu_b = 0;
            4'b0110: alu_b = 1;
            4'b0111: alu_b = 2;
            default: alu_b = 16'hXXXX;
        endcase
    end


    // alu
    alu_wrapper #() alu (
        .out(alu_out),
        .set_flags(f_set),
        .a(alu_a),
        .b(alu_b),
        .opcode(alu_opcode),
        .enable(alu_enable),
        .alu_16b_mode(alu_16b_mode),
        .update_flags(update_flags)
    );

    assign memory_out = alu_out;

    // writeback mux
    always_comb begin
        unique case (write_back_sel)
            2'b00: reg_w_data = alu_out;
            2'b01: reg_w_data = memory_in;
            2'b10: reg_w_data = io_memory_in;
            default: reg_w_data = 16'hXXXX;
        endcase
    end
endmodule
// ###########################
// End of module datapath
// ###########################
