
`timescale 1ns/1ps
`include "alu_op.sv"
`include "mop.sv"
`include "exx_type.sv"
`include "reg_name.sv"
`include "f_op.sv"
`include "mux_enums.sv"

`include "alu_wrapper.sv"
`include "register_file.sv"
`include "buffer.sv"

module datapath (
    input wire              clk,
    input wire              reset,

    // buffers
    input wire              ir_en,
    input wire              o_buff_en,

    // ALU
    input wire              alu_enable,
    input wire              alu_16b_mode,
    input alu_op            alu_opcode,
    input wire [5:0]        update_flags,

    // register file
    input reg_name          reg_a_sel,
    input reg_name          reg_b_sel,
    input reg_name          reg_w_sel,
    input wire              reg_w_en,
    input wire              f_w_en,
    input f_op_enum         f_op,
    input exx_type          exx,
    output wire[5:0]        f, // see the raw_f_buffered output for direct alu flag outputs

    // mux
    input alu_mux_a_enum    alu_mux_a_sel,
    input alu_mux_b_enum    alu_mux_b_sel,
    input write_back_enum   write_back_sel,

    // memory interfacing
    input wire [7:0]        memory_in,
    output wire [15:0]      memory_out, // data or address depending on uop
    input wire [31:0]       instruction_in,

    // instruction decode
    // some of these have corrosponding similarly named inputs from the controller
    output mop              mop_out,
    output reg_name         reg_a_sel_out,
    output reg_name         reg_b_sel_out,
    output wire [7:0]       imm_0_out,
    output wire [15:0]      imm_1_out,
    output wire             use_16b_alu_out,
    output wire [5:0]       update_flags_out,  
    output wire [2:0]       instruction_length_out,

    // misc
    input wire [15:0]       imm_in,
    input wire [2:0]        instruction_length,
    output wire[5:0]        raw_f_buffered
);
    wire [31:0] ir_buff_out;

    // alu and data movement related
    reg  [15:0] alu_a;
    reg  [15:0] alu_b;
    wire [15:0] reg_a;
    wire [15:0] reg_b;
    wire [15:0] o_buff_out;
    wire [15:0] alu_out;
    reg  [15:0] reg_w_data;
    wire [7:0]  memory_buff_out;

    // flags
    wire [5:0] f_raw;
    wire [5:0] f_set;
    wire [5:0] f_reset;
    wire [5:0] f_toggle;


    buffer #(32) instruction_buff(
        .in(instruction_in),
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
        .update_flags(update_flags_out),
        .instruction_length(instruction_length_out)
    );


    // for CCF and SCF instructions. tempted to put this in the register file
    always_comb begin
        case (f_op)
            F_CCF: begin
                f_toggle[0] = 1; // main intent of the CCF instruction
                f_reset[1] = 1; // side effect
            end
            F_SCF: begin
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
        .reg_b(reg_b),
        .reg_w_sel(reg_w_sel),
        .reg_w_data(reg_w_data),
        .reg_w_en(reg_w_en),
        .f_set(f_set),
        .f_reset(f_reset),
        .f_toggle(f_toggle),
        .f_w_en(f_w_en),
        .f(f)
    );


    // op buff
    buffer #(16) op_buff (
        .in(reg_a),
        .w(o_buff_en),
        .clk(clk),
        .reset(reset),
        .out(o_buff_out)
    );


    // alu mux a and mux b
    always_comb begin
        unique case (alu_mux_a_sel)
            A_MUX_O_BUFF        : alu_a = o_buff_out;
            A_MUX_REG_SHIFTED   : alu_a = {reg_a[7:0], 8'h00};
            A_MUX_REG           : alu_a = reg_a;
            default             : alu_a = 16'hXXXX;
        endcase

        unique case (alu_mux_b_sel)
            B_MUX_IMM               : alu_b = imm_in;
            B_MUX_INSTRUCTION_LENGTH: alu_b = {13'b0000000000000, instruction_length};
            B_MUX_m2                : alu_b = -2;
            B_MUX_m1                : alu_b = -1;
            B_MUX_0                 : alu_b = 0;
            B_MUX_1                 : alu_b = 1;
            B_MUX_REG               : alu_b = reg_b;
            default                 : alu_b = 16'hXXXX;
        endcase
    end


    // alu
    alu_wrapper #() alu (
        .out(alu_out),
        .set_flags(f_set),
        .reset_flags(f_reset),
        .toggle_flags(f_toggle),
        .raw_flags(f_raw),
        .a(alu_a),
        .b(alu_b),
        .opcode(alu_opcode),
        .enable(alu_enable),
        .alu_16b_mode(alu_16b_mode),
        .update_flags(update_flags)
    );

    buffer #(6) raw_flag_buff (
        .in(f_raw),
        .w(1'b1),
        .clk(clk),
        .reset(reset),
        .out(raw_f_buffered)
    );

    assign memory_out = alu_out;

    buffer #(8) mem_buff (
        .in(memory_in),
        .w(1'b1),
        .clk(clk),
        .reset(reset),
        .out(memory_buff_out)
    );

    // writeback mux
    always_comb begin
        unique case (write_back_sel)
            WB_MUX_ALU          : reg_w_data = alu_out;
            WB_MUX_MEMORY       : reg_w_data = {8'h00, memory_in};
            WB_MUX_MEMORY_BUFF  : reg_w_data = {memory_buff_out, memory_in};
            default             : reg_w_data = 16'hXXXX;
        endcase
    end
endmodule
