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

    // defail to X if disabled. will output uop INVALID
    assign op_0 = enable ? input_op[31:24] : 'X;
    assign op_1 = enable ? input_op[23:16] : 'X;
    assign op_2 = enable ? input_op[15:8] : 'X;
    assign op_3 = enable ? input_op[7:0] : 'X;

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

    // Decoder programming standards:
    //    if one register is used reg_a is used
    //    if an instruction writes to a register it writes to reg_a. similarly if it writes to (R) then R is also reg_a
    //    imm_0 and imm_1 are used however seems most logical for the whole instruction type. there isn't a great pattern, you'll have to look here
    //    instructions are listed in the same order as the spec
    //    hex is used for whole bytes, otherwise binary
    //    each else/if block is commented with the instruction it is for
    //    order of statements is always the same as in the default definitions at the start of the always_comb

    always_comb begin
        output_op = INVALID;
        reg_a = NONE;
        reg_b = NONE;
        imm_0 = 8'h00;
        imm_1 = 16'h0000;
        use_16b_alu = 0;
        update_flags = 7'b0000000;

        // 8 bit Load
        if (op_0[7:6] == 2'b01) begin //LD r, r'
            output_op = LD_R_R;
            reg_a = reg_from_r(op_0[5:3]);
            reg_b = reg_from_r(op_0[2:0]);
        end else if (op_0[7:6] == 2'b00 && op_0[2:0] == 3'b110) begin // LD r,n
            output_op = LD_R_nn;
            reg_a = reg_from_r(op_0[5:3]);
            imm_1 = {8'h00, op_1}; // use imm_1 so this uop works with the 16b version too
        end else if (op_0[7:6] == 2'b01 && op_0[2:0] == 3'b110) begin // LD r, (HL)
            output_op = LD_R_mRd;
            reg_a = reg_from_r(op_0[5:3]);
            reg_b = HL;
        end else if (op_0 == 8'hDD && op_1[7:6] == 2'b01 && op_1[2:0] == 3'b110) begin // LD r, (IX+d)
            output_op = LD_R_mRd;
            reg_a = reg_from_r(op_1[5:3]);
            reg_b = IX;
            imm_0 = op_2;
        end else if (op_0 == 8'hFD && op_1[7:6] == 2'b01 && op_1[2:0] == 3'b110) begin // LD r, (IY+d)
            output_op = LD_R_mRd;
            reg_a = reg_from_r(op_1[5:3]);
            reg_b = IY;
            imm_0 = op_2;
        end else if (op_0[7:3] == 5'b01110) begin // LD (HL), r
            output_op = LD_mRd_R;
            reg_a = HL;
            reg_b = reg_from_r(op_0[2:0]);
        end else if (op_0 == 8'hDD && op_1[7:3] == 5'b01110) begin // LD (IX+d), r
            output_op = LD_mRd_R;
            reg_a = IX;
            reg_b = reg_from_r(op_1[2:0]);
            imm_0 = op_2; //d
        end else if (op_0 == 8'hFD && op_1[7:3] == 5'b01110) begin // LD (IY+d), r
            output_op = LD_mRd_R;
            reg_a = IY;
            reg_b = reg_from_r(op_1[2:0]);
            imm_0 = op_2; // d
        end else if (op_0 == 8'h36) begin // LD (HL), n
            output_op = LD_mRd_n;
            reg_a = HL;
            imm_1 = {8'h00, op_1}; // n
        end else if (op_0 == 8'hDD && op_1 == 8'h36) begin // LD (IX+d), n
            output_op = LD_mRd_n;
            reg_a = IX;
            imm_0 = op_2; // d
            imm_1 = {8'h00, op_3}; // n
        end else if (op_0 == 8'hFD && op_1 == 8'h36) begin // LD (IY+d), n
            output_op = LD_mRd_n;
            reg_a = IY;
            imm_0 = op_2; // d
            imm_1 = {8'h00, op_3}; // n
        end else if (op_0 == 8'h0A) begin // LD A, (BC)
            output_op = LD_R_mRd;
            reg_a = A;
            reg_b = BC;
        end else if (op_0 == 8'h1A) begin // LD A, (DE)
            output_op = LD_R_mRd;
            reg_a = A;
            reg_b = DE;
        end else if (op_0 == 8'h3A) begin // LD A, (nn)
            output_op = LD_R_mnn;
            reg_a = A;
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'h02) begin // LD (BC), A
            output_op = LD_mRd_R;
            reg_a = BC;
            reg_b = A;
        end else if (op_0 == 8'h12) begin // LD (DE), A
            output_op = LD_mRd_R;
            reg_a = DE;
            reg_b = A;
        end else if (op_0 == 8'h32) begin // LD (nn), A
            output_op = LD_mnn_R;
            reg_a = A;
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hED && op_1 == 8'h57) begin // LD A, I
            output_op = LD_R_R;
            reg_a = A;
            reg_b = I;
            update_flags = 7'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'h5F) begin // LD A, R
            output_op = LD_R_R;
            reg_a = A;
            reg_b = R;
            update_flags = 7'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'h47) begin // LD I, A
            output_op = LD_R_R;
            reg_a = I;
            reg_b = A;
        end else if (op_0 == 8'hED && op_1 == 8'h4F) begin // LD R, A
            output_op = LD_R_R;
            reg_a = R;
            reg_b = A;


        // 8b Arithmetic
        end else if (op_0[7:3] == 5'b10000) begin // ADD A, r
            output_op = ADD_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 7'b1111111;
        

        // General-Purpose
        end else if (op_0 == 8'h00) begin // NOP
            output_op = NOP;


        // Jump
        end else if (op_0 == 8'hC3) begin // JP nn
            output_op = JP_nn;
            imm_1 = {op_2, op_1};
        end else if (op_0[7:6] == 2'b11 && op_0[2:0] == 3'b010) begin // JP cc, nn
            output_op = JP_cc_nn;
            imm_0 = {5'b00000, op_0[5:3]}; // cc
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'h18) begin // JR e
            output_op = JR_e;
            imm_1 = {8'h00, op_1}; // NOTE: imm1 used for e for consistency with other J instructions that use imm0 for cc
        end else if (op_0 == 8'h38) begin // JR C e
            output_op = JR_cc_e;
            imm_0 = 8'b00000011;
            imm_1 = {8'h00, op_1};
        end else if (op_0 == 8'h30) begin // JR NC e
            output_op = JR_cc_e;
            imm_0 = 8'b00000010;
            imm_1 = {8'h00, op_1};
        end else if (op_0 == 8'h28) begin // JR Z e
            output_op = JR_cc_e;
            imm_0 = 8'b00000001;
            imm_1 = {8'h00, op_1};
        end else if (op_0 == 8'h20) begin // JR NZ e
            output_op = JR_cc_e;
            imm_0 = 8'b00000000;
            imm_1 = {8'h00, op_1};
        end else if (op_0 == 8'hE9) begin // JP (HL)
            output_op = JP_mR;
            reg_a = HL;
        end else if (op_0 == 8'hE9) begin // JP (IX)
            output_op = JP_mR;
            reg_a = IX;
        end else if (op_0 == 8'hE9) begin // JP (IY)
            output_op = JP_mR;
            reg_a = IY;
        end else if (op_0 == 8'h10) begin // DJNZ, e
            output_op = DJNZ_e;
            reg_a = B;
            imm_0 = 0'HFF; // -1, possibly useful. Just add imm_0 and reg_a
            imm_1 = {8'h00, op_1};
        end
    end
endmodule
