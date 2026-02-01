`timescale 1ns/1ps

module registerfile_tb();

logic         clk;
logic         reset;
logic         reg8_we;
logic [7:0]   reg8_dst;
logic [7:0]   reg8_data;
logic         reg16_we;
logic [15:0]  reg16_dst;
logic [15:0]  reg16_data;
logic         flags_we;
logic [7:0]   flags;
logic [7:0]   A, B, C, D, E, H, L, F;
logic [15:0]  PC, SP;

parameter [7:0]  reg_A  = 8'h00;
parameter [7:0]  reg_B  = 8'h01;
parameter [7:0]  reg_C  = 8'h02;
parameter [7:0]  reg_D  = 8'h03;
parameter [7:0]  reg_E  = 8'h04;
parameter [7:0]  reg_H  = 8'h05;
parameter [7:0]  reg_L  = 8'h06;
parameter [15:0] reg_BC = 16'h07;
parameter [15:0] reg_DE = 16'h08;
parameter [15:0] reg_HL = 16'h09;
parameter [15:0] reg_SP = 16'h10;

typedef struct {
    logic        is_16bit;
    logic        we_flag;
    logic [15:0] dst;
    logic [15:0] data;
    logic [7:0]  expected_A;
    logic [7:0]  expected_B;
    logic [7:0]  expected_C;
    logic [7:0]  expected_D;
    logic [7:0]  expected_E;
    logic [7:0]  expected_H;
    logic [7:0]  expected_L;
    logic [7:0]  expected_F;
    logic [15:0] expected_SP;
} test_vector;

test_vector testvectors[$];

//! Clock pulse period of 10ns
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

registerfile dut (
    .clk(clk),
    .reset(reset),
    .reg8_we(reg8_we),
    .reg8_dst(reg8_dst),
    .reg8_data(reg8_data),
    .reg16_we(reg16_we),
    .reg16_dst(reg16_dst),
    .reg16_data(reg16_data),
    .flags_we(flags_we),
    .flags(flags),
    .A(A), .B(B), .C(C), .D(D),
    .E(E), .H(H), .L(L), .F(F),
    .PC(PC), .SP(SP)
);

task reset_reg;
    begin
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        @(posedge clk);
    end
endtask

initial begin

    //! Reset state check
    testvectors.push_back('{0,0,0,0,0,0,0,0,0,0,0,0,16'hFFFE});

    //! writing into A and then checking that the value matches
    testvectors.push_back('{0,0,reg_A,16'h0012,8'h12,0,0,0,0,0,0,0,16'hFFFE});

    //! writing into 16 bit register BC and checking if it matches
    testvectors.push_back('{1,0,reg_BC,16'hABCD,8'h12,8'hAB,8'hCD,0,0,0,0,0,16'hFFFE});

    //! updating stack pointer
    testvectors.push_back('{1,0,reg_SP,16'h8000,8'h12,8'hAB,8'hCD,0,0,0,0,0,16'h8000});

    //! test writing to flags register
    testvectors.push_back('{0,1,0,16'h00F0,8'h12,8'hAB,8'hCD,0,0,0,0,8'hF0,16'h8000});

    reg8_we  = 0;
    reg16_we = 0;
    flags_we = 0;

    reset_reg();

    foreach (testvectors[i]) begin
        @(posedge clk);
        #1
        reg8_we  = 0;
        reg16_we = 0;
        flags_we = 0;

        if (testvectors[i].we_flag) begin
            flags_we = 1;
            flags    = testvectors[i].data[7:0];
        end
        else if (testvectors[i].is_16bit) begin
            reg16_we   = 1;
            reg16_dst  = testvectors[i].dst;
            reg16_data = testvectors[i].data;
        end
        else begin
            reg8_we   = 1;
            reg8_dst  = testvectors[i].dst[7:0];
            reg8_data = testvectors[i].data[7:0];
        end

        @(posedge clk);
        #1;

        if ( A  == testvectors[i].expected_A &&
             B  == testvectors[i].expected_B &&
             C  == testvectors[i].expected_C &&
             D  == testvectors[i].expected_D &&
             E  == testvectors[i].expected_E &&
             H  == testvectors[i].expected_H &&
             L  == testvectors[i].expected_L &&
             F  == testvectors[i].expected_F &&
             SP == testvectors[i].expected_SP )
            $display("PASS");
        else
            $display("FAIL");
    end

    $display("ALL TESTS COMPLETE");
    $finish;
end

endmodule