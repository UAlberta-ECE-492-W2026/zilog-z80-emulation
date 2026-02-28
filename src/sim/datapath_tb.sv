`timescale 1ns/1ps
`include "alu_op.sv"

module datapath_tb();

    // ######################
    // Clock / Reset
    // ######################
    logic clk;
    logic reset;

    // Clock pulse period of 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ######################
    // DUT controls
    // ######################
    logic        alu_enable;
    alu_op       alu_opcode;

    logic [1:0]  alu_a_sel, alu_b_sel;
    logic [7:0]  reg8_src_a, reg8_src_b;
    logic [7:0]  imm8;

    logic        reg8_we;
    logic [7:0]  reg8_dst;
    logic [1:0]  reg8_wsel;

    logic        reg16_we;
    logic [15:0] reg16_dst;
    logic [15:0] reg16_wdata;

    logic        flags_we;
    logic        flags_sel;
    logic [7:0]  flags_in;

    logic [7:0]  mem_rdata;

    // ######################
    // DUT outputs / taps
    // ######################
    logic [7:0]  alu_out;
    logic [7:0]  alu_flags;

    logic [7:0]  A, B, C, D, E, H, L, F;
    logic [15:0] PC, SP;

    // ######################
    // Register encoding constants
    // ######################
    parameter [7:0]  reg_A  = 8'h00;
    parameter [7:0]  reg_B  = 8'h01;
    parameter [7:0]  reg_C  = 8'h02;
    parameter [7:0]  reg_D  = 8'h03;
    parameter [7:0]  reg_E  = 8'h04;
    parameter [7:0]  reg_H  = 8'h05;
    parameter [7:0]  reg_L  = 8'h06;

    // ######################
    // Instantiate DUT
    // ######################
    datapath dut (
        .clk(clk),
        .reset(reset),

        .alu_enable(alu_enable),
        .alu_opcode(alu_opcode),

        .alu_a_sel(alu_a_sel),
        .alu_b_sel(alu_b_sel),
        .reg8_src_a(reg8_src_a),
        .reg8_src_b(reg8_src_b),
        .imm8(imm8),

        .reg8_we(reg8_we),
        .reg8_dst(reg8_dst),
        .reg8_wsel(reg8_wsel),

        .reg16_we(reg16_we),
        .reg16_dst(reg16_dst),
        .reg16_wdata(reg16_wdata),

        .flags_we(flags_we),
        .flags_sel(flags_sel),
        .flags_in(flags_in),

        .mem_rdata(mem_rdata),

        .alu_out(alu_out),
        .alu_flags(alu_flags),

        .A(A), .B(B), .C(C), .D(D),
        .E(E), .H(H), .L(L), .F(F),
        .PC(PC), .SP(SP)
    );

    // ######################
    // Reset task
    // ######################
    task reset_reg;
        begin
            reset = 1;
            repeat(2) @(posedge clk);
            reset = 0;
            @(posedge clk);
        end
    endtask

    // ######################
    // Test vectors
    // ######################
    typedef struct {
        // controls for one "micro-step"
        logic        do_write_imm;   // write imm8 into reg8_dst
        logic        do_alu;         // perform ALU op and writeback to reg8_dst
        alu_op       opcode;

        logic [7:0]  dst;
        logic [7:0]  srcA;
        logic [7:0]  srcB;
        logic [7:0]  imm;

        // expected end state (after step)
        logic [7:0]  expected_A;
        logic [7:0]  expected_B;
        logic [7:0]  expected_F;
    } test_vector;

    test_vector testvectors[$];

    // ######################
    // Main test program
    // ######################
    initial begin
        // VCD like your other benches
        $dumpfile("out/sim/datapath_tb.vcd");
        $dumpvars();

        // Default inputs
        alu_enable  = 0;
        alu_opcode  = NOP;

        alu_a_sel   = 2'b00;
        alu_b_sel   = 2'b00;
        reg8_src_a  = reg_A;
        reg8_src_b  = reg_B;
        imm8        = 8'h00;

        reg8_we     = 0;
        reg8_dst    = 8'h00;
        reg8_wsel   = 2'b00;

        reg16_we    = 0;
        reg16_dst   = 16'h0000;
        reg16_wdata = 16'h0000;

        flags_we    = 0;
        flags_sel   = 0;
        flags_in    = 8'h00;

        mem_rdata   = 8'h00;

        // ######################
        // Define tests (push_back style)
        // ######################

        //! After reset, A,B,F should be 0
        testvectors.push_back('{0, 0, NOP, 8'h00, 8'h00, 8'h00, 8'h00,
                               8'h00, 8'h00, 8'h00});

        //! A = 0x05
        testvectors.push_back('{1, 0, NOP, reg_A, 8'h00, 8'h00, 8'h05,
                               8'h05, 8'h00, 8'h00});

        //! B = 0x03
        testvectors.push_back('{1, 0, NOP, reg_B, 8'h00, 8'h00, 8'h03,
                               8'h05, 8'h03, 8'h00});

        //! A = A + B = 0x08 (flags from ALU)
        testvectors.push_back('{0, 1, ADD, reg_A, reg_A, reg_B, 8'h00,
                               8'h08, 8'h03, 8'h00}); // expected_F here is “don’t care" for now

        //! A = A - B = 0x05
        testvectors.push_back('{0, 1, SUB, reg_A, reg_A, reg_B, 8'h00,
                               8'h05, 8'h03, 8'h00});

        //! A = A & B = 0x01
        testvectors.push_back('{0, 1, AND, reg_A, reg_A, reg_B, 8'h00,
                               8'h01, 8'h03, 8'h00});

        //! A = A XOR A = 0x00, expect Z flag = 1 (Z is bit 6 in your alu_status)
        //! We check F[6] explicitly below, so expected_F can be 0 here.
        testvectors.push_back('{0, 1, XOR, reg_A, reg_A, reg_A, 8'h00,
                               8'h00, 8'h03, 8'h00});

        // ######################
        // Run
        // ######################
        reset_reg();

        foreach (testvectors[i]) begin
            @(posedge clk);
            #1;

            // Default idle each step
            alu_enable = 0;
            reg8_we    = 0;
            flags_we   = 0;

            // Apply one step
            if (testvectors[i].do_write_imm) begin
                // reg8_wsel = 01 => imm8
                imm8      = testvectors[i].imm;
                reg8_dst  = testvectors[i].dst;
                reg8_wsel = 2'b01;
                reg8_we   = 1;
            end
            else if (testvectors[i].do_alu) begin
                alu_opcode = testvectors[i].opcode;
                alu_enable = 1;

                // ALU operands from regs
                alu_a_sel  = 2'b00;
                alu_b_sel  = 2'b00;
                reg8_src_a = testvectors[i].srcA;
                reg8_src_b = testvectors[i].srcB;

                // writeback ALU out
                reg8_dst   = testvectors[i].dst;
                reg8_wsel  = 2'b00;
                reg8_we    = 1;

                // latch flags from ALU
                flags_sel  = 0;
                flags_we   = 1;
            end

            // Let it latch on next clock
            @(posedge clk);
            #1;

            // Check state (same PASS/FAIL style)
            if (A == testvectors[i].expected_A &&
                B == testvectors[i].expected_B) begin

                // For the last vector: check Z flag specifically
                if (i == (testvectors.size()-1)) begin
                    if (F[6] == 1'b1)
                        $display("PASS");
                    else
                        $display("FAIL");
                end
                else begin
                    $display("PASS");
                end
            end
            else begin
                $display("FAIL");
            end
        end

        $display("ALL TESTS COMPLETE");
        $finish;
    end

endmodule