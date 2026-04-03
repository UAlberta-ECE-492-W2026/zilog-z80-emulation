`timescale 1ns/1ps
`include "alu_op.sv"

module alu_wrapper #() 
(
    input wire enable,
    input wire alu_16b_mode,
    input alu_op opcode,
    input wire [5:0] update_flags,
    input wire [5:0] current_flags,
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [15:0] out,
    output reg [5:0] set_flags,
    output reg [5:0] reset_flags,
    output reg [5:0] toggle_flags,
    output reg [5:0] raw_flags
);  
    reg alu_8_en;
    reg alu_16_en;
    reg bit_alu_en;

    wire [7:0] out_8;
    wire [15:0] out_16;
    wire [7:0]  bit_out_8;

    wire [5:0] flags_8;
    wire [5:0] flags_16;
    wire [5:0] bit_raw_flags;
    wire [5:0] bit_set_flags;
    wire [5:0] bit_reset_flags;


    always_comb begin
        out = 0;

        bit_alu_en = 0;
        alu_8_en = 0;
        alu_16_en = 0;

        set_flags = 0;
        reset_flags = 0;
        toggle_flags = 0;

        raw_flags = 0;

        if (enable && opcode != ALU_NOP) begin
            if ( (opcode == ALU_BIT) || (opcode == ALU_SETBIT) || (opcode == ALU_RESBIT)) begin // bit operation
                out = {8'h00, bit_out_8};
                bit_alu_en = ~alu_16b_mode;
                set_flags = bit_set_flags;
                reset_flags = bit_reset_flags;
                raw_flags = bit_raw_flags;

            end else begin // normal ALU operation
                if (alu_16b_mode) begin
                    out  = out_16;
                    alu_16_en = 1;
                    set_flags = flags_16 & update_flags;
                    raw_flags = flags_16;

                end else begin
                    out = {8'h00, out_8};
                    alu_8_en = 1;
                    set_flags = flags_8 & update_flags;
                    raw_flags = flags_8;
                end
                reset_flags = (~raw_flags) & update_flags & current_flags;
            end
        end
    end

    alu #(8) alu_8 (
        .a(a[7:0]),
        .b(b[7:0]),
        .opcode(opcode),
        .enable(alu_8_en),
        .flags_in(current_flags),
        .status_flag(flags_8),
        .out(out_8)
    );
    alu #(16) alu_16 (
        .a(a),
        .b(b),
        .opcode(opcode),
        .enable(alu_16_en),
        .flags_in(current_flags),
        .status_flag(flags_16),
        .out(out_16)

    );

    alu_bit_op bit_alu (
        .enable(bit_alu_en),
        .opcode(opcode),
        .a(a[7:0]),
        .bit_index(b[2:0]),
        .out(bit_out_8),
        .raw_flags(bit_raw_flags),
        .set_flags(bit_set_flags),
        .reset_flags(bit_reset_flags)
    );

endmodule
