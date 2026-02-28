`timescale 1ns/1ps
`include "reg_name.sv"
`include "exx_type.sv"

/* verilator lint_off UNUSEDSignal */
task display_input_output_expected_registerfile(input 
        exx_type    exx, 
        reg_name    reg_a_sel, 
        reg_name    reg_b_sel, 
        reg_name    reg_w_sel, 
        reg[15:0]   reg_w_data, 
        reg         reg_w_en, 
        reg[5:0]    f_set, 
        reg[5:0]    f_reset, 
        reg[5:0]    f_toggle, 
        reg         f_w_en, 
        reg[15:0]   reg_a, 
        reg[15:0]   reg_b, 
        reg[5:0]    f, 
        reg[15:0]   pc, 
        reg[15:0]   expected_reg_a, 
        reg[15:0]   expected_reg_b, 
        reg[5:0]    expected_f, 
        reg[15:0]   expected_pc
    );

    $write("%9s | %9s | %9s | %9s | 16'h%h   | 1'b%b     | 6'b%b | 6'b%b | 6'b%b | 1'b%b   | 16'h%h | 16'h%h | 6'b%b | 16'h%h\n", exx.name, reg_a_sel.name, reg_b_sel.name,reg_w_sel.name, reg_w_data, reg_w_en, f_set, f_reset, f_toggle, f_w_en, reg_a, reg_b, f, pc);
    $write(" Expected:                                                                                                         | 16'h%h | 16'h%h | 6'b%b | 16'h%h", expected_reg_a, expected_reg_b, expected_f, expected_pc);

endtask // display_input_output_expected

module register_file_tb();

    reg          clk;
    reg          reset;

    // exchange input
    exx_type     exx;

    // register read ports
    reg_name     reg_a_sel;
    reg_name     reg_b_sel;
    wire[15:0]   reg_a;
    wire[15:0]   reg_b;

    // register write port
    reg_name     reg_w_sel;
    reg [15:0]   reg_w_data;
    reg          reg_w_en;

    // flags
    reg [5:0]    f_set;
    reg [5:0]    f_reset;
    reg [5:0]    f_toggle;
    reg          f_w_en;
    reg [5:0]    f;

    // PC output
    wire[15:0]  pc;


    typedef struct {
        //inputs
        exx_type   exx;
        reg_name   reg_a_sel;
        reg_name   reg_b_sel;
        reg_name   reg_w_sel;
        reg [15:0] reg_w_data;
        reg        reg_w_en;
        reg [5:0]  f_set;
        reg [5:0]  f_reset;
        reg [5:0]  f_toggle;
        reg        f_w_en;

        //expected outputs
        reg[15:0]  expected_reg_a;
        reg[15:0]  expected_reg_b;
        reg[5:0]   expected_f;
        reg[15:0]  expected_pc;
    } test_vector;

    test_vector testvectors[$];

    //! Clock pulse period of 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    register_file dut (
        .clk(clk),
        .reset(reset),
        .exx(exx),
        .reg_a_sel(reg_a_sel),
        .reg_b_sel(reg_b_sel),
        .reg_a(reg_a),
        .reg_b(reg_b),
        .reg_w_sel(reg_w_sel),
        .reg_w_data(reg_w_data),
        .reg_w_en(reg_w_en),
        .f_set(f_set),
        .f_reset(f_reset),
        .f_toggle(f_toggle),
        .f_w_en(f_w_en),
        .f(f),
        .pc(pc)
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
        //                      exx,       reg_a_sel, reg_b_sel, reg_w_sel, reg_w_data, reg_w_en, f_set,     f_reset,   f_toggle, f_w_en, reg_a,    reg_b,    f,         pc
        //! Reset state check
    //  testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0}); // blank template

        testvectors.push_back('{EX_NONE,   A,         B,         NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});

        //! writing into A and then checking that the value matches
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      A,         16'hDEAD,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});
        testvectors.push_back('{EX_NONE,   A,         NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h00AD, 16'h0000, 0,         0}); // only exepect to get the lower 8 bits since A is 8b.

        //! writing into 16 bit register BC and checking readback
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      BC,        16'hBEEF,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});
        testvectors.push_back('{EX_NONE,   BC,        NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'hBEEF, 16'h0000, 0,         0});

        //! updating stack pointer. also try out the other read port
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      SP,        16'h1234,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});
        testvectors.push_back('{EX_NONE,   NONE,      SP,        NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h0000, 16'h1234, 0,         0});

        //! test writing to flags register
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      F,         16'h00AA,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 6'b100010, 0}); // note how the two X bits are dropped from the output
        testvectors.push_back('{EX_NONE,   F,         NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h00AA, 16'h0000, 6'b100010, 0}); // full value with X bits are returned when reading as normal register
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'h0000,   0,        0,         6'b000000, 0,        1,      16'h0000, 16'h0000, 6'b000000, 0}); // reset all flags
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'h0000,   0,        6'b101010, 0,         0,        1,      16'h0000, 16'h0000, 6'b101010, 0}); // set some flags
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'h0000,   0,        0,         0,         0'b000111,1,      16'h0000, 16'h0000, 6'b101101, 0}); // toggle
        testvectors.push_back('{EX_NONE,   F,         NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h0099, 16'h0000, 6'b101101, 0}); // read out on port a
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'h0000,   0,        0,         6'b000000, 0,        1,      16'h0000, 16'h0000, 6'b000000, 0}); 

        // check pc output
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      PC,        16'hF00D,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      NONE,      16'hF00D,   0,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         16'hF00D});
        testvectors.push_back('{EX_NONE,   NONE,      NONE,      PC,        16'h0000,   1,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         16'hF00D});

        // exchange testing
        //testvectors.push_back('{EX_AF_AFp, NONE,      NONE,      NONE,      16'h0000,   0,        0,         0,         0,        0,      16'h0000, 16'h0000, 0,         0});

        reset_reg();

      	$display("exx       | reg_a_sel | reg_b_sel | reg_w_sel | reg_w_data | reg_w_en | f_set     | f_reset   | f_toggle  | f_w_en | reg_a    | reg_b    | f         | pc");

        for (int i = 0; i < $size(testvectors); ++i) begin
            #10;
            exx         = testvectors[i].exx;
            reg_a_sel   = testvectors[i].reg_a_sel;
            reg_b_sel   = testvectors[i].reg_b_sel;
            reg_w_sel   = testvectors[i].reg_w_sel;
            reg_w_data  = testvectors[i].reg_w_data;
            reg_w_en    = testvectors[i].reg_w_en;
            f_set       = testvectors[i].f_set;
            f_reset     = testvectors[i].f_reset;
            f_toggle    = testvectors[i].f_toggle;
            f_w_en      = testvectors[i].f_w_en;

            display_input_output_expected_registerfile(
                exx, 
                reg_a_sel, 
                reg_b_sel,
                reg_w_sel, 
                reg_w_data, 
                reg_w_en, 
                f_set, 
                f_reset, 
                f_toggle, 
                f_w_en, 
                reg_a, 
                reg_b, 
                f, 
                pc, 
                testvectors[i].expected_reg_a, 
                testvectors[i].expected_reg_b, 
                testvectors[i].expected_f, 
                testvectors[i].expected_pc
            );

            if (
                testvectors[i].expected_reg_a == reg_a && 
                testvectors[i].expected_reg_b == reg_b &&
                testvectors[i].expected_f == f &&
                testvectors[i].expected_pc == pc
            ) 
            begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL");
            end
            #1;
        end

        $display("ALL TESTS COMPLETE");
        $finish;
    end
endmodule
