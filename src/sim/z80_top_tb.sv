`timescale 1ns/1ps
/* verilator lint_off UNUSEDSIGNAL */
task display_input_output_expected_z_80_top(input
                                            int        i,
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
                                            reg [63:0] expected_test_ram);

    $write(" %2d |    %h | %h | %h | %h | %h | %h | %h \n", i, instruction, af, bc, ix, sp, pc, test_ram);

    $write("    |             | %h | %h | %h | %h | %h | %h |", expected_af, expected_bc, expected_ix, expected_sp, expected_pc, expected_test_ram);
endtask
/* verilator lint_on UNUSEDSIGNAL */

module z80_top_tb #() ();
    parameter clock_period = 10;

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
    uop::uop_t state;

    logic tb_reset;
    assign buttons = {3'b000, tb_reset};

    reg all_pass = 1;

    /* synchronization primitive to decouple test timing from vector application */
    event test_start;
    event frame_start;
    event frame_end;

    logic [1:0] test_frame_state;

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
        forever #( clock_period / 2 ) clk = ~clk;
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
        .test_ram(test_ram),
        .state(state)
    );

    /* verilator lint_off UNUSEDSIGNAL */
    task reset_tb;
        begin
            tb_reset = 1;
            repeat(2) @(posedge clk);
            tb_reset = 0;
            @(posedge clk);
        end
    endtask
    /* verilator lint_on UNUSEDSIGNAL */

    initial begin
        test_frame_state = 0;
        wait (test_start.triggered);
        forever begin
            @(state == uop::fetch && ! clk);
            ->frame_start;
            test_frame_state = 1;
            @(posedge clk);
            #( clock_period / 8 );
            test_frame_state = 2;
            @(state == uop::fetch);
            ->frame_end;
            test_frame_state = 3;
        end
    end

    initial begin
        $dumpfile("out/sim/z80_top_tb.vcd");
        $dumpvars();
        //                                    AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back('{32'h00000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0002, 64'h0000000000000000}); // NOP
        testvectors.push_back('{32'h3e070000, 16'h0700, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000}); // ld        a,$07
        testvectors.push_back('{32'h47000000, 16'h0700, 16'h0700, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000}); // ld        b,a
        testvectors.push_back('{32'h01efbe00, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0008, 64'h0000000000000000}); // ld        bc,$beef
        testvectors.push_back('{32'hed4f0000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h000A, 64'h0000000000000000}); // ld        r,a
        testvectors.push_back('{32'h3e670000, 16'h6700, 16'hbeef, 16'h0000, 16'h0000, 16'h000C, 64'h0000000000000000}); // ld        a,$67
        testvectors.push_back('{32'hed5f0000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h000E, 64'h0000000000000000}); // ld        a,r
        testvectors.push_back('{32'hed470000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0010, 64'h0000000000000000}); // ld        i,a
        testvectors.push_back('{32'h3e230000, 16'h2300, 16'hbeef, 16'h0000, 16'h0000, 16'h0012, 64'h0000000000000000}); // ld        a,$23
        testvectors.push_back('{32'hed570000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0014, 64'h0000000000000000}); // ld        a,i
        testvectors.push_back('{32'hdd213713, 16'h0700, 16'hbeef, 16'h1337, 16'h0000, 16'h0018, 64'h0000000000000000}); // ld        ix,$1337
        testvectors.push_back('{32'hfd210190, 16'h0700, 16'hbeef, 16'h1337, 16'h0000, 16'h001C, 64'h0000000000000000}); // ld        iy,$9001
        testvectors.push_back('{32'hfdf90000, 16'h0700, 16'hbeef, 16'h1337, 16'h9001, 16'h001E, 64'h0000000000000000}); // ld        sp,iy
        testvectors.push_back('{32'hddf90000, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0020, 64'h0000000000000000}); // ld        sp,ix
        testvectors.push_back('{32'h11341200, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0023, 64'h0000000000000000}); // ld        de,$1234
        testvectors.push_back('{32'h21785600, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0026, 64'h0000000000000000}); // ld        hl,$5678
        testvectors.push_back('{32'heb000000, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0027, 64'h0000000000000000}); // ex        de,hl
        testvectors.push_back('{32'h7a000000, 16'h5600, 16'hbeef, 16'h1337, 16'h1337, 16'h0028, 64'h0000000000000000}); // ld        a,d
        testvectors.push_back('{32'h7c000000, 16'h1200, 16'hbeef, 16'h1337, 16'h1337, 16'h0029, 64'h0000000000000000}); // ld        a,h
        testvectors.push_back('{32'h21998800, 16'h1200, 16'hbeef, 16'h1337, 16'h1337, 16'h002C, 64'h0000000000000000}); // ld        hl,$8899
        testvectors.push_back('{32'hf9000000, 16'h1200, 16'hbeef, 16'h1337, 16'h8899, 16'h002D, 64'h0000000000000000}); // ld        sp,hl
        testvectors.push_back('{32'h80000000, 16'hd000, 16'hbeef, 16'h1337, 16'h8899, 16'h002E, 64'h0000000000000000}); // add       b
        testvectors.push_back('{32'hd6010000, 16'hcf00, 16'hbeef, 16'h1337, 16'h8899, 16'h0030, 64'h0000000000000000}); // sub       $01
        testvectors.push_back('{32'hb0000000, 16'hff00, 16'hbeef, 16'h1337, 16'h8899, 16'h0031, 64'h0000000000000000}); // or        b
        testvectors.push_back('{32'hc34d0000, 16'hff00, 16'hbeef, 16'h1337, 16'h8899, 16'h004d, 64'h0000000000000000}); // JP        $4d
        testvectors.push_back('{32'h00000000, 16'hff00, 16'hbeef, 16'h1337, 16'h8899, 16'h004e, 64'h0000000000000000}); // NOP
        testvectors.push_back('{32'h31100000, 16'hff00, 16'hbeef, 16'h1337, 16'h0010, 16'h0051, 64'h0000000000000000}); // ld        sp,$0010
        testvectors.push_back('{32'hf5000000, 16'hff00, 16'hbeef, 16'h1337, 16'h000e, 16'h0052, 64'h00000000000000ff}); // push      af
        testvectors.push_back('{32'hdde50000, 16'hff00, 16'hbeef, 16'h1337, 16'h000c, 16'h0054, 64'h00000000371300ff}); // push      ix
        testvectors.push_back('{32'hfde50000, 16'hff00, 16'hbeef, 16'h1337, 16'h000a, 16'h0056, 64'h00000190371300ff}); // push      iy
        testvectors.push_back('{32'hdde10000, 16'hff00, 16'hbeef, 16'h9001, 16'h000c, 16'h0058, 64'h00000190371300ff}); // pop       ix
        testvectors.push_back('{32'hfde10000, 16'hff00, 16'hbeef, 16'h9001, 16'h000e, 16'h005a, 64'h00000190371300ff}); // pop       iy
        testvectors.push_back('{32'hc1000000, 16'hff00, 16'hff00, 16'h9001, 16'h0010, 16'h005b, 64'h00000190371300ff}); // pop       bc
        testvectors.push_back('{32'h21040000, 16'hff00, 16'hff00, 16'h9001, 16'h0010, 16'h005e, 64'h00000190371300ff}); // ld        hl,$0004
        testvectors.push_back('{32'hdd210100, 16'hff00, 16'hff00, 16'h0001, 16'h0010, 16'h0062, 64'h00000190371300ff}); // ld        ix,$0001
        testvectors.push_back('{32'hfd210200, 16'hff00, 16'hff00, 16'h0001, 16'h0010, 16'h0066, 64'h00000190371300ff}); // ld        iy,$0002
        testvectors.push_back('{32'h34000000, 16'hff00, 16'hff00, 16'h0001, 16'h0010, 16'h0067, 64'h00000190381300ff}); // inc       (hl)
        testvectors.push_back('{32'hdd340b00, 16'hff00, 16'hff00, 16'h0001, 16'h0010, 16'h006a, 64'h00000190391300ff}); // inc       (ix+$0b)
        testvectors.push_back('{32'hfd340a00, 16'hff00, 16'hff00, 16'h0001, 16'h0010, 16'h006d, 64'h000001903a1300ff}); // inc       (iy+$0a)
        testvectors.push_back('{32'h7e000000, 16'h3a00, 16'hff00, 16'h0001, 16'h0010, 16'h006e, 64'h000001903a1300ff}); // ld        a,(hl)
        testvectors.push_back('{32'hdd7e0100, 16'h0100, 16'hff00, 16'h0001, 16'h0010, 16'h0071, 64'h000001903a1300ff}); // ld        a,(ix+$01)
        testvectors.push_back('{32'hfd7e0200, 16'h3a00, 16'hff00, 16'h0001, 16'h0010, 16'h0074, 64'h000001903a1300ff}); // ld        a,(iy+$02)
        testvectors.push_back('{32'h01020000, 16'h3a00, 16'h0002, 16'h0001, 16'h0010, 16'h0077, 64'h000001903a1300ff}); // ld        bc,$0002
        testvectors.push_back('{32'h11030000, 16'h3a00, 16'h0002, 16'h0001, 16'h0010, 16'h007a, 64'h000001903a1300ff}); // ld        de,$0003
        testvectors.push_back('{32'h0a000000, 16'h0100, 16'h0002, 16'h0001, 16'h0010, 16'h007b, 64'h000001903a1300ff}); // ld        a,(bc)
        testvectors.push_back('{32'h1a000000, 16'h9000, 16'h0002, 16'h0001, 16'h0010, 16'h007c, 64'h000001903a1300ff}); // ld        a,(de)
        testvectors.push_back('{32'h3e000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h007e, 64'h000001903a1300ff}); // ld        a,$00
        testvectors.push_back('{32'h77000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h007f, 64'h00000190001300ff}); // ld        (hl),a
        testvectors.push_back('{32'hdd770400, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0082, 64'h00000190000000ff}); // ld        (ix+$04),a
        testvectors.push_back('{32'hfd770500, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0085, 64'h0000019000000000}); // ld        (iy+$05),a
        testvectors.push_back('{32'h02000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0086, 64'h0000009000000000}); // ld        (bc),a
        testvectors.push_back('{32'h12000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0087, 64'h0000000000000000}); // ld        (de),a
        testvectors.push_back('{32'h36080000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0089, 64'h0000000008000000}); // ld        (hl),$08
        testvectors.push_back('{32'hdd360409, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h008d, 64'h0000000008090000}); // ld        (ix+$04),$09
        testvectors.push_back('{32'hfd360107, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0091, 64'h0000000708090000}); // ld        (iy+$01),$07
        testvectors.push_back('{32'h76000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0091, 64'h0000000708090000}); // HALT
        testvectors.push_back('{32'h76000000, 16'h0000, 16'h0002, 16'h0001, 16'h0010, 16'h0091, 64'h0000000708090000}); // HALT

        reset_tb();
        ->test_start;


        $display("idx | instruction |   AF |   BC |   IX |   SP |   PC | memory    ");

        foreach (testvectors[i]) begin
            /* application of the test vector in the fetch region */
            @frame_start;
            instruction = testvectors[i].instruction;

            /* assertion region of the testbench */
            @frame_end;
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
                testvectors[i].test_ram == {
                                            test_ram[0],
                                            test_ram[1],
                                            test_ram[2],
                                            test_ram[3],
                                            test_ram[4],
                                            test_ram[5],
                                            test_ram[6],
                                            test_ram[7]}
                )
            begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL at time = %f", $realtime);
                all_pass = 0;
            end
            $display("");
        end
        
        if (all_pass == 1) begin
            $display("ALL TESTS PASS");
        end else begin
            $display("FAILING TESTS!");
        end
        $finish;
    end

endmodule
