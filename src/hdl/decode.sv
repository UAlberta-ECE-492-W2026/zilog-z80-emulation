`timescale 1ns/1ps
`include "mop.sv"
`include "reg_name.sv"
/* verilator lint_off UNUSEDSIGNAL */

module decode #(

) (
    input wire [31:0] input_op,
    input wire enable,
    output mop output_op,
    output reg_name reg_a,
    output reg_name reg_b,
    output wire [7:0] imm_0,
    output wire [15:0] imm_1,
    output wire use_16b_alu,
    output wire [5:0] update_flags
);
    // this helps make it a bit easier to read and compare to the specification
    wire [7:0] op_0; //first byte
    wire [7:0] op_1; // second byte
    wire [7:0] op_2;
    wire [7:0] op_3;

    // defail to X if disabled. will output mop INVALID
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

    // translate 16b register codes ('dd' in spec) to reg_name
    function reg_name reg_from_dd (reg[1:0] dd);
        case(dd)
            2'b00: reg_from_dd = BC;
            2'b01: reg_from_dd = DE;
            2'b10: reg_from_dd = HL;
            2'b11: reg_from_dd = SP;
            default: reg_from_dd = NONE;
        endcase
    endfunction

    // translate the other kind of 16b register codes ('qq' in spec) to reg_name
    function reg_name reg_from_qq (reg[1:0] qq);
        case(qq)
            2'b00: reg_from_qq = BC;
            2'b01: reg_from_qq = DE;
            2'b10: reg_from_qq = HL;
            2'b11: reg_from_qq = AF;
            default: reg_from_qq = NONE;
        endcase
    endfunction

    // translate the other other kind of 16b register codes ('pp' in spec) to reg_name
    function reg_name reg_from_pp (reg[1:0] pp);
        case(pp)
            2'b00: reg_from_pp = BC;
            2'b01: reg_from_pp = DE;
            2'b10: reg_from_pp = IX;
            2'b11: reg_from_pp = SP;
            default: reg_from_pp = NONE;
        endcase
    endfunction

    // translate the other other other kind of 16b register codes ('rr' in spec) to reg_name
    function reg_name reg_from_rr (reg[1:0] rr);
        case(rr)
            2'b00: reg_from_rr = BC;
            2'b01: reg_from_rr = DE;
            2'b10: reg_from_rr = IX;
            2'b11: reg_from_rr = SP;
            default: reg_from_rr = NONE;
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
        update_flags = 6'b000000;

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
            update_flags = 6'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'h5F) begin // LD A, R
            output_op = LD_R_R;
            reg_a = A;
            reg_b = R;
            update_flags = 6'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'h47) begin // LD I, A
            output_op = LD_R_R;
            reg_a = I;
            reg_b = A;
        end else if (op_0 == 8'hED && op_1 == 8'h4F) begin // LD R, A
            output_op = LD_R_R;
            reg_a = R;
            reg_b = A;


        // 16b load
        end else if (op_0[7:6] == 2'b00 && op_0[3:0] == 4'b0001) begin // LD dd, nn
            output_op = LD_R_nn;
            reg_a = reg_from_dd(op_0[5:4]);
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hDD && op_1 == 8'h21) begin // LD IX, nn
            output_op = LD_R_nn;
            reg_a = IX;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'hDD && op_1 == 8'h21) begin // LD IY, nn
            output_op = LD_R_nn;
            reg_a = IY;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'h2A) begin // LD HL, (nn)
            output_op = LD_R_mnn;
            reg_a = HL;
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hED && op_1[7:6] == 2'b01 && op_1[3:0] == 4'b1011) begin // LD dd, (nn)
            output_op = LD_R_mnn;
            reg_a = reg_from_dd(op_1[5:4]);
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hDD && op_1 == 8'h2A) begin // LD IX, (nn)
            output_op = LD_R_mnn;
            reg_a = IX;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'hFD && op_1 == 8'h2A) begin // LD IY, (nn)
            output_op = LD_R_mnn;
            reg_a = IY;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'h22) begin // LD (nn), HL
            output_op = LD_mnn_R;
            reg_a = HL;
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hED && op_1[7:6] == 2'b01 && op_1[3:0] == 4'b0011) begin // LD (nn), dd
            output_op = LD_mnn_R;
            reg_a = reg_from_dd(op_1[5:4]);
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'hDD && op_1 == 8'h22) begin // LD (nn), IX
            output_op = LD_mnn_R;
            reg_a = IX;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'hFD && op_1 == 8'h22) begin // LD (nn), IY
            output_op = LD_mnn_R;
            reg_a = IY;
            imm_1 = {op_3, op_2};
        end else if (op_0 == 8'hF9) begin // LD SP, HL
            output_op = LD_R_R;
            reg_a = SP;
            reg_b = HL;
        end else if (op_0 == 8'hDD && op_1 == 8'hF9) begin // LD SP, IX
            output_op = LD_R_R;
            reg_a = SP;
            reg_b = IX;
        end else if (op_0 == 8'hFD && op_1 == 8'hF9) begin // LD SP, IX
            output_op = LD_R_R;
            reg_a = SP;
            reg_b = IY;
        end else if (op_0[7:6] == 2'b11 && op_0[3:0] == 4'b0101) begin  // PUSH qq
            output_op = PUSH_R;
            reg_a = SP;
            reg_b = reg_from_qq(op_0[5:4]);
        end else if (op_0 == 8'hDD && op_1 == 8'hE5) begin // PUSH IX
            output_op = PUSH_R;
            reg_a = SP;
            reg_b = IX;
        end else if (op_0 == 8'hFD && op_1 == 8'hE5) begin // PUSH IY
            output_op = PUSH_R;
            reg_a = SP;
            reg_b = IY;
        end else if (op_0[7:6] == 0'b11 && op_0[3:0] == 4'b0001) begin // POP qq
            output_op = POP_R;
            reg_a = reg_from_qq(op_0[5:4]);
            reg_b = SP;
        end else if (op_0 == 8'hDD && op_1 == 8'hE1) begin // POP IX
            output_op = POP_R;
            reg_a = IX;
            reg_b = SP;
        end else if (op_0 == 8'hFD && op_1 == 8'hE1) begin // POP IY
            output_op = POP_R;
            reg_a = IY;
            reg_b = SP;


        // Exchange, Block Transfer, and Search
        end else if (op_0 == 8'hEB) begin // EX DE, HL
            output_op = EX_R_R;
            reg_a = DE;
            reg_b = HL;
        end else if (op_0 == 8'h08) begin // EX AF, AF′
            output_op = EX_R_Rp;
            reg_a = AF;
        end else if (op_0 == 8'hD9) begin // EXX
            output_op = EXX;
        end else if (op_0 == 8'hE3) begin // EX (SP), HL
            output_op = EX_mR_R;
            reg_a = SP;
            reg_b = HL;
        end else if (op_0 == 8'hDD && op_1 == 8'hE3) begin // EX (SP), IX
            output_op = EX_mR_R;
            reg_a = SP;
            reg_b = IX;
        end else if (op_0 == 8'hFD && op_1 == 8'hE3) begin // EX (SP), IY
            output_op = EX_mR_R;
            reg_a = SP;
            reg_b = IY;
        end else if (op_0 == 8'hED && op_1 == 8'hA0) begin // LDI
            output_op = LD_block;
            imm_0 = 8'h01; // for LD_block imm_0 is added to DE and HL
            update_flags = 6'b001110;
        end else if (op_0 == 8'hED && op_1 == 8'hB0) begin // LDIR
            output_op = LD_block;
            imm_0 = 8'h01; 
            imm_1 = 16'hFFFE; // -2. Add to PC.
            update_flags = 6'b001110;
        end else if (op_0 == 8'hED && op_1 == 8'hA8) begin // LDD
            output_op = LD_block;
            imm_0 = 8'hFF; // -1. make sure to sign extend
            update_flags = 6'b001110;
        end else if (op_0 == 8'hED && op_1 == 8'hB8) begin // LDDR
            output_op = LD_block;
            imm_0 = 8'hFF; // -1. make sure to sign extend
            imm_1 = 16'hFFFE; // -2. Add to PC.
            update_flags = 6'b001110;
        end else if (op_0 == 8'hED && op_1 == 8'hA1) begin // CPI
            output_op = CP_block;
            imm_0 = 8'h01; // for CP_block imm_0 is added to HL
            update_flags = 6'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'hB9) begin // CPIR
            output_op = CP_block;
            imm_0 = 8'h01; // for CP_block imm_0 is added to HL
            imm_1 = 16'hFFFE; // -2. Add to PC.
            update_flags = 6'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'hA9) begin // CPD
            output_op = CP_block;
            imm_0 = 8'hFF; // -1 add to HL
            update_flags = 6'b111110;
        end else if (op_0 == 8'hED && op_1 == 8'hB9) begin // CPDR
            output_op = CP_block;
            imm_0 = 8'hFF; // -1 add to HL
            imm_1 = 16'hFFFE; // -2. Add to PC.
            update_flags = 6'b111110;

        // 8b Arithmetic
        end else if (op_0[7:3] == 5'b10000) begin // ADD A, r
            output_op = ADD_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hC6) begin // ADD A, n
            output_op = ADD_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'h86) begin // ADD A, (HL)
            output_op = ADD_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'h86) begin // ADD A, (IX + d)
            output_op = ADD_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'h86) begin // ADD A, (IY + d)
            output_op = ADD_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10001) begin // ADC A, r
            output_op = ADC_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hCE) begin // ADC A, n
            output_op = ADC_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'h8E) begin // ADC A, (HL)
            output_op = ADC_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'h8E) begin // ADC A, (IX + d)
            output_op = ADC_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'h8E) begin // ADC A, (IY + d)
            output_op = ADC_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10010) begin // SUB A, r
            output_op = SUB_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hD6) begin // SUB A, n
            output_op = SUB_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'h96) begin // SUB A, (HL)
            output_op = SUB_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'h96) begin // SUB A, (IX + d)
            output_op = SUB_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'h96) begin // SUB A, (IY + d)
            output_op = SUB_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10011) begin // SBC A, r
            output_op = SBC_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDE) begin // SBC A, n
            output_op = SBC_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'h9E) begin // SBC A, (HL)
            output_op = SBC_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'h9E) begin // SBC A, (IX + d)
            output_op = SBC_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'h9E) begin // SBC A, (IY + d)
            output_op = SBC_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10100) begin // AND A, r
            output_op = AND_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hE6) begin // AND A, n
            output_op = AND_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'hA6) begin // AND A, (HL)
            output_op = AND_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'hA6) begin // AND A, (IX + d)
            output_op = AND_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'hA6) begin // AND A, (IY + d)
            output_op = AND_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;
        
        end else if (op_0[7:3] == 5'b10110) begin // OR A, r
            output_op = OR_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hF6) begin // OR A, n
            output_op = OR_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'hB6) begin // OR A, (HL)
            output_op = OR_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'hB6) begin // OR A, (IX + d)
            output_op = OR_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'hB6) begin // OR A, (IY + d)
            output_op = OR_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10101) begin // XOR A, r
            output_op = XOR_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hEE) begin // XOR A, n
            output_op = XOR_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'hAE) begin // XOR A, (HL)
            output_op = XOR_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'hAE) begin // XOR A, (IX + d)
            output_op = XOR_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'hAE) begin // XOR A, (IY + d)
            output_op = XOR_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:3] == 5'b10111) begin // CP A, r
            output_op = CP_R_R;
            reg_a = A;
            reg_b = reg_from_r(op_0[2:0]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFE) begin // CP A, n
            output_op = CP_R_nn;
            reg_a = A;
            imm_1 = {8'h00, op_1}; // zero extend shouldn't matter since we use the 8b alu
            update_flags = 6'b111111;
        end else if (op_0 == 8'hBE) begin // CP A, (HL)
            output_op = CP_R_mRd;
            reg_a = A;
            reg_b = HL;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1 == 8'hBE) begin // CP A, (IX + d)
            output_op = CP_R_mRd;
            reg_a = A;
            reg_b = IX;
            imm_0 = op_2;
            update_flags = 6'b111111;
        end else if (op_0 == 8'hFD && op_1 == 8'hBE) begin // CP A, (IY + d)
            output_op = CP_R_mRd;
            reg_a = A;
            reg_b = IY;
            imm_0 = op_2;
            update_flags = 6'b111111;

        end else if (op_0[7:6] == 2'b00 && op_0[2:0] == 3'b100) begin // INC r
            output_op = ADD_R_nn;
            reg_a = reg_from_r(op_0[5:3]);
            imm_1 = {16'h0001};
            update_flags = 6'b111110;
        end else if (op_0 == 8'h34) begin // INC (HL)
            output_op = INC_mRd;
            reg_a = HL;
            update_flags = 6'b111110;
        end else if (op_0 == 8'hDD && op_1 == 8'h34) begin // INC (IX+d)
            output_op = INC_mRd;
            reg_a = IX;
            imm_0 = op_2;
            update_flags = 6'b111110;
        end else if (op_0 == 8'hFD && op_1 == 8'h34) begin // INC (IY+d)
            output_op = INC_mRd;
            reg_a = IY;
            imm_0 = op_2;
            update_flags = 6'b111110;

        end else if (op_0[7:6] == 2'b00 && op_0[2:0] == 3'b101) begin // DEC r
            output_op = SUB_R_nn;
            reg_a = reg_from_r(op_0[5:3]);
            imm_1 = {16'h0001};
            update_flags = 6'b111110;
        end else if (op_0 == 8'h35) begin // DEC (HL)
            output_op = DEC_mRd;
            reg_a = HL;
            update_flags = 6'b111110;
        end else if (op_0 == 8'hDD && op_1 == 8'h35) begin // DEC (IX+d)
            output_op = DEC_mRd;
            reg_a = IX;
            imm_0 = op_2;
            update_flags = 6'b111110;
        end else if (op_0 == 8'hFD && op_1 == 8'h35) begin // DEC (IY+d)
            output_op = DEC_mRd;
            reg_a = IY;
            imm_0 = op_2;
            update_flags = 6'b111110;


        // General-Purpose
        end else if (op_0 == 8'h27) begin // DAA
            output_op = DAA;
            update_flags = 6'b111101;
        end else if (op_0 == 8'h2F) begin // CPL
            output_op = CPL;
            update_flags = 6'b001010;
        end else if (op_0 == 8'hED && op_1 == 8'h44) begin // NEG
            output_op = NEG;
            update_flags = 6'b111111;
        end else if (op_0 == 8'h3F) begin // CCF
            output_op = CCF;
            update_flags = 6'b001011;
        end else if (op_0 == 8'h37) begin // SCF
            output_op = SCF;
            update_flags = 6'b001011;
        end else if (op_0 == 8'h00) begin // NOP
            output_op = NOP;
        end else if (op_0 == 8'h76) begin // HALT
            output_op = HALT;
        end else if (op_0 == 8'hF3) begin // DI
            output_op = DI;
        end else if (op_0 == 8'hFB) begin // EI
            output_op = EI;
        end else if (op_0 == 8'hED && op_0 == 8'h46) begin // IM 0
            output_op = IM0;
        end else if (op_0 == 8'hED && op_0 == 8'h56) begin // IM 1
            output_op = IM1;
        end else if (op_0 == 8'hED && op_0 == 8'h5E) begin // IM2
            output_op = IM2;


        // 16b math
        end else if (op_0[7:6] == 2'b00 && op_0[3:0] == 4'b1001) begin // ADD HL, ss
            output_op = ADD_R_R;
            reg_a = HL;
            reg_b = reg_from_dd(op_0[5:4]); // 'ss' is used in the spec, but it acts the same as dd
            update_flags = 6'b0010101;
        end else if (op_0 == 8'hED && op_1[7:6] == 2'b01 && op_1[3:0] == 4'b1010) begin // ADC HL, ss
            output_op = ADC_R_R;
            reg_a = HL;
            reg_b = reg_from_dd(op_1[5:4]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hED && op_1[7:6] == 2'b01 && op_1[3:0] == 4'b0010) begin // SBC HL, ss
            output_op = SBC_R_R;
            reg_a = HL;
            reg_b = reg_from_dd(op_1[5:4]);
            update_flags = 6'b111111;
        end else if (op_0 == 8'hDD && op_1[7:6] == 2'b00 && op_1[3:0] == 4'b1001) begin // ADD IX, pp
            output_op = ADD_R_R;
            reg_a = IX;
            reg_b = reg_from_pp(op_1[5:4]);
            update_flags = 6'b001011;
        end else if (op_0 == 8'hFD && op_1[7:6] == 2'b00 && op_1[3:0] == 4'b1001) begin // ADD IY, rr
            output_op = SBC_R_R;
            reg_a = IY;
            reg_b = reg_from_rr(op_1[5:4]);
            update_flags = 6'b001011;
        end else if (op_0[7:6] == 2'b00 && op_0[3:0] == 4'b0011) begin // INC ss
            output_op = ADD_R_nn;
            reg_a = reg_from_dd(op_0[5:4]);
            imm_1 = 16'h01;
        end else if (op_0 == 8'hDD && op_1 == 8'h23) begin // INC IX
            output_op = ADD_R_nn;
            reg_a = IX;
            imm_1 = 16'h01;
        end else if (op_0 == 8'hFD && op_1 == 8'h23) begin // INC IY
            output_op = ADD_R_nn;
            reg_a = IY;
            imm_1 = 16'h01;
        end else if (op_0[7:6] == 2'b00 && op_0[3:0] == 4'b1011) begin // DEC ss
            output_op = SUB_R_nn;
            reg_a = reg_from_dd(op_0[5:4]);
            imm_1 = 16'h01;
        end else if (op_0 == 8'hDD && op_1 == 8'h2B) begin // DEC IX
            output_op = SUB_R_nn;
            reg_a = IX;
            imm_1 = 16'h01;
        end else if (op_0 == 8'hFD && op_1 == 8'h2B) begin // DEC IY
            output_op = SUB_R_nn;
            reg_a = IY;
            imm_1 = 16'h01;

        /* Shift and Rotate *************************************************/
        end else if (op_0 == 8'h07) begin // RLCA
           output_op = RLC_R;
           reg_a = A;
           update_flags = 6'b001011;

        end else if (op_0 == 8'h17) begin // RLA
           output_op = RL_R;
           reg_a = A;
           update_flags = 6'b001011;
        end else if (op_0 == 8'h0F) begin // RRCA
           output_op = RRC_R;
           reg_a = A;
           update_flags = 6'b001011;
        end else if (op_0 == 8'h1F) begin //RRA
           output_op = RR_R;
           reg_a = A;
           update_flags = 6'b001011;
        end else if (op_0 == 8'hCB) begin
           update_flags = 6'b111111;
           /* shared first byte */
           if (op_1 == 06) begin // RLC HL
              output_op = RLC_mRd;
              reg_a = HL;
           end else begin // RLC r
              output_op = RLC_R;
              reg_a = reg_from_r(op_1[2:0]);
           end
        end else if (op_0 == 8'hDD && op_1 == 8'hCB && op_3 == 8'h06) begin // RLC (IX+d)
           output_op = RLC_mRd;
           reg_a = IX;


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
            imm_1 = {8'h00, op_1}; // NOTE: imm_1 used for e for consistency with other J instructions that use imm_0 for cc
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
            output_op = JP_R;
            reg_a = HL;
        end else if (op_0 == 8'hE9) begin // JP (IX)
            output_op = JP_R;
            reg_a = IX;
        end else if (op_0 == 8'hE9) begin // JP (IY)
            output_op = JP_R;
            reg_a = IY;
        end else if (op_0 == 8'h10) begin // DJNZ, e
            output_op = DJNZ_e;
            reg_a = B;
            imm_0 = 0'HFF; // -1, possibly useful. Just add imm_0 and reg_a
            imm_1 = {8'h00, op_1};


        // Call and Return
        end else if (op_0 == 8'hCD) begin // CALL nn
            output_op = CALL_nn;
            imm_1 = {op_2, op_1};
        end else if (op_0[7:6] == 2'b11 && op_0[2:0] == 3'b100) begin // CALL cc, nn
            output_op = CALL_cc_nn;
            imm_0 = {5'b00000, op_0[5:3]};
            imm_1 = {op_2, op_1};
        end else if (op_0 == 8'hC9) begin //RET
            output_op = RET;
        end else if (op_0[7:6] == 2'b11 && op_0[2:0] == 3'b100) begin //RET cc
            output_op = RET_cc;
            imm_0 = {5'b00000, op_0[5:3]};
        end else if (op_0 == 8'hED && op_1 == 8'h4D) begin // RETI
            output_op = RETI;
        end else if (op_0 == 8'hED && op_1 == 8'h45) begin // RETN
            output_op = RETN;
        end else if (op_0[7:6] == 2'b11 && op_0[2:0] == 3'b111) begin
            output_op = RST_p;
            imm_0 = {op_0[5:3], 5'b00000}; // p is just shifted t
        end
    end
endmodule
