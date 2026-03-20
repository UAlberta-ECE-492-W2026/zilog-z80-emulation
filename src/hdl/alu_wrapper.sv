`include "alu_op.sv"

module alu_wrapper #() 
(
    input wire enable,
    input wire alu_16b_mode,
    input alu_op opcode,
    input wire [5:0] update_flags, 
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] out,
    output wire [5:0] set_flags,
    output wire [5:0] reset_flags,
    output wire [5:0] toggle_flags,
    output wire [5:0] raw_flags
);
    wire alu_8_en;
    wire alu_16_en;
    assign alu_8_en   = (alu_16b_mode == 0) ? (enable && opcode != ALU_NOP && !is_bit_op) : 0;
    assign alu_16_en  = (alu_16b_mode == 1) ? (enable && opcode != ALU_NOP) : 0;

    wire [7:0] out_8;
    wire [15:0] out_16;
    assign out = (alu_16b_mode == 1) ? out_16 : {8'h00, out_8};

    wire [5:0] flags_8;
    wire [5:0] flags_16;
    wire [5:0] bit_raw_flags;
    wire [5:0] bit_set_flags;
    wire [5:0] bit_reset_flags;

    assign set_flags = is_bit_op ? bit_set_flags : (raw_flags & update_flags);
    assign raw_flags = is_bit_op ? bit_raw_flags : ((alu_16b_mode == 1) ? flags_16 : flags_8);
    
    // will likely need these once the alu actually supports all the required flag behavior
    assign reset_flags = is_bit_op ? bit_reset_flags : 0;
    assign toggle_flags = 0;

    wire is_bit_op;
    assign is_bit_op  = (opcode == ALU_BIT) || (opcode == ALU_SETBIT) || (opcode == ALU_RESBIT);

    wire bit_alu_en;
    assign bit_alu_en = (alu_16b_mode == 0) ? (enable && is_bit_op) : 0;

    wire [7:0]  bit_out_8;

    assign out = is_bit_op ? {8'h00, bit_out_8} : ((alu_16b_mode == 1) ? out_16 : {8'h00, out_8});

    alu #(8) alu_8 (
        .a(a[7:0]),
        .b(b[7:0]),
        .opcode(opcode),
        .enable(alu_8_en),
        .status_flag(flags_8),
        .out(out_8)
    );
    alu #(16) alu_16 (
        .a(a),
        .b(b),
        .opcode(opcode),
        .enable(alu_16_en),
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
