`timescale 1ns/1ps

//! This module implements the 8-bit and 16-bit register file that was defined in the Zilog Z80

module registerfile
(
input  logic        clk,
input  logic        reset,
input  logic        reg8_we,
input  reg   [7:0]  reg8_dst,
input  logic [7:0]  reg8_data,
input  logic        reg16_we,
input  reg   [15:0] reg16_dst,
input  logic [15:0] reg16_data,
input  logic        flags_we,
input  logic [7:0]  flags,
output logic [7:0]  A, B, C, D, E, H, L, F,
output logic [15:0] PC, SP
);

parameter [7:0] reg_A  = 8'h00;
parameter [7:0] reg_B  = 8'h01;
parameter [7:0] reg_C  = 8'h02;
parameter [7:0] reg_D  = 8'h03;
parameter [7:0] reg_E  = 8'h04;
parameter [7:0] reg_H  = 8'h05;
parameter [7:0] reg_L  = 8'h06;
parameter [15:0] reg_BC = 16'h07;
parameter [15:0] reg_DE = 16'h08;
parameter [15:0] reg_HL = 16'h09;
parameter [15:0] reg_SP = 16'h10;

function automatic [7:0] read_reg8(input reg [7:0] register);
    case (register)
        reg_A: read_reg8 = A;
        reg_B: read_reg8 = B;
        reg_C: read_reg8 = C;
        reg_D: read_reg8 = D;
        reg_E: read_reg8 = E;
        reg_H: read_reg8 = H;
        reg_L: read_reg8 = L;
        default: read_reg8 = 8'h0;
    endcase
endfunction

function automatic [15:0] read_reg16(input reg [15:0] register_register);
    case (register_register)
        reg_BC: read_reg16 = {B, C};
        reg_DE: read_reg16 = {D, E};
        reg_HL: read_reg16 = {H, L};
        reg_SP: read_reg16 = SP;
        default: read_reg16 = 16'h0;
    endcase
endfunction

//! Initialization of registers
always_ff @(posedge clk) begin
    if (reset) begin
        A  <= 8'h0;
        B  <= 8'h0;
        C  <= 8'h0;
        D  <= 8'h0;
        E  <= 8'h0;
        H  <= 8'h0;
        L  <= 8'h0;
        F  <= 8'h0;
        PC <= 16'h0;
        SP <= 16'hFFFE;
    end else begin

        if (reg8_we) begin
            case (reg8_dst)
                reg_A: A <= reg8_data;
                reg_B: B <= reg8_data;
                reg_C: C <= reg8_data;
                reg_D: D <= reg8_data;
                reg_E: E <= reg8_data;
                reg_H: H <= reg8_data;
                reg_L: L <= reg8_data;
                default;
            endcase
        end

        if (reg16_we) begin
            case (reg16_dst[15:0])
                reg_BC: begin B <= reg16_data[15:8]; C <= reg16_data[7:0]; end
                reg_DE: begin D <= reg16_data[15:8]; E <= reg16_data[7:0]; end
                reg_HL: begin H <= reg16_data[15:8]; L <= reg16_data[7:0]; end
                reg_SP: SP <= reg16_data;
                default;
            endcase
        end

        if (flags_we) begin
            F <= flags;
        end
    end
end

endmodule