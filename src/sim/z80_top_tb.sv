`timescale 1ns/1ps
/* verilator lint_off UNUSEDSIGNAL */
task display_input_output_expected_z_80_top(input
                                            int i,
                                            reg [31:0] instruction,
                                            reg [15:0] af,
                                            reg [15:0] bc,
                                            reg [15:0] ix,
                                            reg [15:0] sp,
                                            reg [15:0] pc,
                                            reg [63:0] test_ram,
                                            reg [15:0] expected_af,
                                            reg [15:0] expected_bc,
                                            reg [15:0] expected_ix,
                                            reg [15:0] expected_sp,
                                            reg [15:0] expected_pc,
                                            reg [63:0] expected_test_ram,

    );

    $write(" %2d |   %h | %h | %h | %h | %h | %h | %h \n", i, instruction, af, bc, ix, sp, pc, test_ram);

    $write("    |          | %h | %h | %h | %h | %h | %h |", expected_af, expected_bc, expected_ix, expected_sp, expected_pc, expected_test_ram);
endtask
/* verilator lint_on UNUSEDSIGNAL */

module z80_top_tb #() ();
    // display driving outputs. not tested here
    /* verilator lint_off UNUSEDSIGNAL */
    logic hsync;
    logic vsync;
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;

    // other top level IO
    logic[3:0] buttons;
    logic[3:0] LEDs;


    // useful debug interfaces
    logic [7:0] main_reg_set [0:7];
    logic [15:0] special_reg_set [0:4];
    logic [7:0] test_ram [0:7];
    logic [31:0] instruction;

    logic reset;
    assign buttons = {3'b000, reset};

    reg all_pass = 1;

    // clock
    logic clk;
    /* verilator lint_on UNUSEDSIGNAL */
    
    typedef struct {
        //inputs
        reg [31:0]   instruction;

        //expected outputs
        reg[15:0]  AF;
        reg[15:0]  BC;
        reg[15:0]  IX;
        reg[15:0]  SP;
        reg[15:0]  PC;
        reg[63:0]  test_ram;
    } test_vector;

    test_vector testvectors[$];

    //! Clock pulse period of 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    z80_top_for_testing #() dut (
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .buttons(buttons),
        .LEDs(LEDs),
        .clk(clk),
        .main_reg_set(main_reg_set),
        .special_reg_set(special_reg_set),
        .instruction(instruction),
        .test_ram(test_ram)
    );

    /* verilator lint_off UNUSEDSIGNAL */
    task reset_tb;
        begin
            reset = 1;
            repeat(2) @(posedge clk);
            reset = 0;
            @(posedge clk);
        end
    endtask
    /* verilator lint_on UNUSEDSIGNAL */

    initial begin
        $dumpfile("out/sim/z80_top_tb.vcd");
        $dumpvars();

        testvectors.push_back('{32'h00000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 64'h0000000000000000}); // NOP
        testvectors.push_back('{32'h3e070000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 64'h0000000000000000}); // ld        a,$07
        testvectors.push_back('{32'h00000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 64'h0000000000000000}); // NOP
        testvectors.push_back('{32'h00000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 64'h0000000000000000}); // NOP

        reset_tb();

        $display("idx | instruction |   AF |   BC |   IX |   SP |   PC | memory    ");

        for (int i = 0; i < $size(testvectors); ++i) begin
            instruction = testvectors[i].instruction;

            #1
            display_input_output_expected_z_80_top(
                i,
                instruction,
                {main_reg_set[0], main_reg_set[1]},
                {main_reg_set[2], main_reg_set[3]},
                special_reg_set[1],
                special_reg_set[3],
                special_reg_set[4],
                {test_ram[0],test_ram[1],test_ram[2],test_ram[3],test_ram[4],test_ram[5],test_ram[6],test_ram[7]},
                testvectors[i].AF, 
                testvectors[i].BC, 
                testvectors[i].IX,
                testvectors[i].SP,
                testvectors[i].PC,
                testvectors[i].test_ram
            );

            if (
                testvectors[i].AF == {main_reg_set[0], main_reg_set[1]} &&
                testvectors[i].BC == {main_reg_set[2], main_reg_set[3]} &&
                testvectors[i].IX == special_reg_set[1] &&
                testvectors[i].SP == special_reg_set[3] &&
                testvectors[i].PC == special_reg_set[4] &&
                testvectors[i].test_ram == {test_ram[0],test_ram[1],test_ram[2],test_ram[3],test_ram[4],test_ram[5],test_ram[6],test_ram[7]}
            ) 
            begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL at time = %f", $realtime);
                all_pass = 0;
            end
            $display("");
            #9;
        end
        
        if (all_pass == 1) begin
            $display("ALL TESTS PASS");
        end else begin
            $display("FAILING TESTS!");
        end
        $finish;
    end

endmodule
