`timescale 1ns/1ps
`include "alu_op.sv"

module alu_bit_op(
    input wire enable,
    input alu_op opcode,
    input wire [7:0] a,
    input wire [2:0] bit_index,

    output wire [7:0] out,
    output wire [5:0] raw_flags,
    output wire [5:0] set_flags,
    output wire [5:0] reset_flags
);
    // External project flag order:
    // {S, Z, H, P/V, N, C}
    reg [7:0] out_var;
    reg [5:0] raw_var;
    reg [5:0] set_var;
    reg [5:0] reset_var;

    wire bit_val;
    assign bit_val = a[bit_index];

    assign out         = enable ? out_var   : 8'hZZ;
    assign raw_flags   = enable ? raw_var   : 6'bZZZZZZ;
    assign set_flags   = enable ? set_var   : 6'b000000;
    assign reset_flags = enable ? reset_var : 6'b000000;

    always_comb begin
        out_var   = a;
        raw_var   = 6'b000000;
        set_var   = 6'b000000;
        reset_var = 6'b000000;

        unique case (opcode)
            ALU_BIT: begin
                // Follow the current project decode intent:
                // update_flags for BIT is already 6'b011010, so only
                // Z/H/N are meant to be updated through this path.
                //
                // Z = ~bit_val
                // H = 1
                // N = 0
                // C unchanged
                raw_var[4] = ~bit_val;  // Z
                raw_var[3] = 1'b1;      // H

                set_var[4]   = ~bit_val;  // set Z when tested bit is 0
                set_var[3]   = 1'b1;      // set H
                reset_var[4] = bit_val;   // clear Z when tested bit is 1
                reset_var[1] = 1'b1;      // clear N
            end
            ALU_SETBIT: begin
                out_var = a | (8'h01 << bit_index);
            end
            ALU_RESBIT: begin
                out_var = a & ~(8'h01 << bit_index);
            end
            default: begin
            end
        endcase
    end
endmodule
