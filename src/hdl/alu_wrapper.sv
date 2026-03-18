`include "alu_op.sv"
`include "alu.sv"

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
    assign alu_8_en = (alu_16b_mode == 0) ? (enable  && opcode != ALU_NOP) : 0;
    assign alu_16_en = (alu_16b_mode == 1) ? (enable  && opcode != ALU_NOP) : 0;

    wire [7:0] out_8;
    wire [15:0] out_16;
    assign out = (alu_16b_mode == 1) ? out_16 : {8'h00, out_8};

    wire [5:0] flags_8;
    wire [5:0] flags_16;

    assign set_flags = raw_flags & update_flags;
    assign raw_flags = (alu_16b_mode == 1) ? flags_16 : flags_8;
    
    // will likely need these once the alu actually supports all the required flag behavior
    assign reset_flags = 0;
    assign toggle_flags = 0;

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

endmodule
