`timescale 1ns/1ps
`include "uop.sv"
`include "reg_name.sv"
/* verilator lint_off UNUSEDSIGNAL */

module decode #(

) (
    input wire [31:0] input_op,
    input wire enable,
    output uop output_op,
    output reg_name reg_a,
    output reg_name reg_b,
    output wire [7:0] imm_0,
    output wire [15:0] imm_1,
    output wire use_16b_alu,
    output wire [6:0] update_flags
);
    // this helps make it a bit easier to read and compare to the specification
    wire [7:0] op_0; //first byte
    wire [7:0] op_1; // second byte
    wire [7:0] op_2;
    wire [7:0] op_3;

    assign op_0 = enable ? input_op[31:24] : 'X;
    assign op_1 = input_op[23:16];
    assign op_2 = input_op[15:8];
    assign op_3 = input_op[7:0];

    // translates general purpose register codes (denoted as 'r' in spec) to internally used reg_name type
    function reg_name reg_from_r (reg[2:0] r);
        case(r)
            3'b111: reg_from_r = A;
            3'b000: reg_from_r = B;
            3'b001: reg_from_r = C;
            3'b010: reg_from_r = D;
            3'b011: reg_from_r = E;
            3'b100: reg_from_r = H;
            3'b101: reg_from_r = L;
            default: reg_from_r = NONE;
        endcase
    endfunction

    always_comb begin
        output_op = INVALID;
        reg_a = NONE;
        reg_b = NONE;
        imm_0 = 8'h00;
        imm_1 = 16'h0000;
        use_16b_alu = 0;
        update_flags = 7'b0000000;
        case(op_0[7:6])
            2'b00: begin
            end
            2'b01: begin
                output_op = LD_R_R;
                reg_a = reg_from_r(op_0[5:3]);
                reg_b = reg_from_r(op_0[2:0]);
            end
            2'b10: begin
            end
            2'b11: begin
            end
        endcase


    end
endmodule
