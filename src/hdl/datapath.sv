
`timescale 1ns/1ps
`include "alu_op.sv"

module datapath (
    input logic clk,
    input logic reset,

    // ######################
    // ALU control
    // ######################
    input  logic        alu_enable,
    input  alu_op       alu_opcode,

    // Select ALU operand sources
    // 00 = reg8 (selected by reg8_src_*)
    // 01 = immediate (imm8)
    // 10 = constant 0
    // 11 = constant 8'hFF
    input  logic [1:0]  alu_a_sel,
    input  logic [1:0]  alu_b_sel,
    input  logic [7:0]  reg8_src_a,
    input  logic [7:0]  reg8_src_b,
    input  logic [7:0]  imm8,

    // ######################
    // Register writeback control
    // ######################
    input  logic        reg8_we,
    input  logic [7:0]  reg8_dst,

    // 00 = ALU out
    // 01 = imm8
    // 10 = mem_rdata
    // 11 = passthrough reg8_src_a
    input  logic [1:0]  reg8_wsel,

    input  logic        reg16_we,
    input  logic [15:0] reg16_dst,
    input  logic [15:0] reg16_wdata,

    // ######################
    // Flags writeback control
    // ######################
    input  logic        flags_we,

    // 0 = ALU status flags
    // 1 = flags_in (explicit)
    input  logic        flags_sel,
    input  logic [7:0]  flags_in,

    // ######################
    // Memory datapath hooks (optional)
    // ######################
    input  logic [7:0]  mem_rdata,

    // ######################
    // Debug / taps
    // ######################
    output logic [7:0]  alu_out,
    output logic [7:0]  alu_flags,

    output logic [7:0]  A, B, C, D, E, H, L, F,
    output logic [15:0] PC, SP
);

    // ############################################
    // Register encoding constants (must match registerfile.sv)
    // ############################################
    localparam logic [7:0]  REG_A  = 8'h00;
    localparam logic [7:0]  REG_B  = 8'h01;
    localparam logic [7:0]  REG_C  = 8'h02;
    localparam logic [7:0]  REG_D  = 8'h03;
    localparam logic [7:0]  REG_E  = 8'h04;
    localparam logic [7:0]  REG_H  = 8'h05;
    localparam logic [7:0]  REG_L  = 8'h06;

    localparam logic [15:0] REG_BC = 16'h07;
    localparam logic [15:0] REG_DE = 16'h08;
    localparam logic [15:0] REG_HL = 16'h09;
    localparam logic [15:0] REG_SP = 16'h10;

    // ############################################
    // Internal wires
    // ############################################
    logic [7:0] reg8_a_val;
    logic [7:0] reg8_b_val;
    logic [7:0] alu_a;
    logic [7:0] alu_b;

    logic [7:0] reg8_wdata;
    logic [7:0] flags_wdata;

    // ############################################
    // Helper functions: read an 8-bit or 16-bit register from the exposed taps
    // ############################################
    function automatic logic [7:0] read_reg8(input logic [7:0] r);
        unique case (r)
            REG_A:   read_reg8 = A;
            REG_B:   read_reg8 = B;
            REG_C:   read_reg8 = C;
            REG_D:   read_reg8 = D;
            REG_E:   read_reg8 = E;
            REG_H:   read_reg8 = H;
            REG_L:   read_reg8 = L;
            default: read_reg8 = 8'h00;
        endcase
    endfunction

    function automatic logic [15:0] read_reg16(input logic [15:0] rr);
        unique case (rr)
            REG_BC:  read_reg16 = {B, C};
            REG_DE:  read_reg16 = {D, E};
            REG_HL:  read_reg16 = {H, L};
            REG_SP:  read_reg16 = SP;
            default: read_reg16 = 16'h0000;
        endcase
    endfunction

    // ##############
    // Read sources
    // ##############
    always_comb begin
        reg8_a_val = read_reg8(reg8_src_a);
        reg8_b_val = read_reg8(reg8_src_b);
    end

    // ###################
    // ALU operand muxes
    // ###################
    always_comb begin
        unique case (alu_a_sel)
            2'b00: alu_a = reg8_a_val;
            2'b01: alu_a = imm8;
            2'b10: alu_a = 8'h00;
            2'b11: alu_a = 8'hFF;
            default: alu_a = 8'h00;
        endcase

        unique case (alu_b_sel)
            2'b00: alu_b = reg8_b_val;
            2'b01: alu_b = imm8;
            2'b10: alu_b = 8'h00;
            2'b11: alu_b = 8'hFF;
            default: alu_b = 8'h00;
        endcase
    end

    // #######################
    // ALU
    // #######################
    wire [7:0] alu_out_w;
    wire [7:0] alu_flags_w;

    alu #(.alu_width(8)) u_alu (
        .out(alu_out_w),
        .status_flag(alu_flags_w),
        .a(alu_a),
        .b(alu_b),
        .opcode(alu_opcode),
        .enable(alu_enable)
    );

    always_comb begin
        alu_out   = alu_out_w;
        alu_flags = alu_flags_w;
    end

    // ##########################
    // 8-bit register writeback mux
    // ##########################
    always_comb begin
        unique case (reg8_wsel)
            2'b00: reg8_wdata = alu_out_w;
            2'b01: reg8_wdata = imm8;
            2'b10: reg8_wdata = mem_rdata;
            2'b11: reg8_wdata = reg8_a_val;
            default: reg8_wdata = 8'h00;
        endcase
    end

    // ######################
    // Flags writeback mux
    // ######################
    always_comb begin
        flags_wdata = (flags_sel == 1'b0) ? alu_flags_w : flags_in;
    end

    // ##########################
    // Register file
    // ##########################
    registerfile u_rf (
        .clk(clk),
        .reset(reset),

        .reg8_we(reg8_we),
        .reg8_dst(reg8_dst),
        .reg8_data(reg8_wdata),

        .reg16_we(reg16_we),
        .reg16_dst(reg16_dst),
        .reg16_data(reg16_wdata),

        .flags_we(flags_we),
        .flags(flags_wdata),

        .A(A), .B(B), .C(C), .D(D), .E(E), .H(H), .L(L), .F(F),
        .PC(PC), .SP(SP)
    );    
endmodule
// ###########################
// End of module datapath
// ###########################
