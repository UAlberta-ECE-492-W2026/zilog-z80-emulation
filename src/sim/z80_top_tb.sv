`timescale 1ns/1ps

`define SV_TESTBENCH
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

    $write(" %3d |    %h | %h | %h | %h | %h | %h | %h \n", i, instruction, af, bc, ix, sp, pc, test_ram);

    $write("     |             | %h | %h | %h | %h | %h | %h |", expected_af, expected_bc, expected_ix, expected_sp, expected_pc, expected_test_ram);
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

    /* test meta data */
    logic [1:0] test_frame_state;
    logic [31:0] test_idx;


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
        logic      reset;
    } test_vector;

    /**
     constructor function that abstracts out optional parameters for the test
     vector struct.
     */
    function automatic test_vector cons_test(
        //inputs
        /* verilator lint_off UNUSEDSIGNAL */
        reg [31:0] instr,

        //expected outputs
        reg [15:0] af,
        reg [15:0] bc,
        reg [15:0] ix,
        reg [15:0] sp,
        reg [15:0] pc,
        reg [63:0] t_ram,

        logic      assert_reset = 0, // optional parameters
        /* verilator lint_on UNUSEDSIGNAL */
                                             );
        return '{instr, af, bc, ix, sp, pc, t_ram, assert_reset};
    endfunction; // cons_test

    /**
     * helper constructor that creates a reset blob
     */
    function automatic test_vector cons_reset();
        return cons_test(32'h00000000,
                         16'h0000,
                         16'h0000,
                         16'h0000,
                         16'h0000,
                         16'h0001,
                         64'h0000000000000000,
                         .assert_reset(1));
    endfunction; // cons_reset



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
        .override_instruction(1'b1),
        .test_ram(test_ram),
        .state(state)
    );

    /* verilator lint_off UNUSEDSIGNAL */
    task reset_tb;
        begin
            tb_reset = 1;
            repeat(4) @(posedge clk);
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

        //                              instruction   AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back(cons_reset()); // load instruction group
        testvectors.push_back(cons_test(32'h00000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0002, 64'h0000000000000000)); // NOP
        testvectors.push_back(cons_test(32'h3e070000, 16'h0700, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // ld        a,$07
        testvectors.push_back(cons_test(32'h47000000, 16'h0700, 16'h0700, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000)); // ld        b,a
        testvectors.push_back(cons_test(32'h01efbe00, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0008, 64'h0000000000000000)); // ld        bc,$beef
        testvectors.push_back(cons_test(32'hed4f0000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h000A, 64'h0000000000000000)); // ld        r,a
        testvectors.push_back(cons_test(32'h3e670000, 16'h6700, 16'hbeef, 16'h0000, 16'h0000, 16'h000C, 64'h0000000000000000)); // ld        a,$67
        testvectors.push_back(cons_test(32'hed5f0000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h000E, 64'h0000000000000000)); // ld        a,r
        testvectors.push_back(cons_test(32'hed470000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0010, 64'h0000000000000000)); // ld        i,a
        testvectors.push_back(cons_test(32'h3e230000, 16'h2300, 16'hbeef, 16'h0000, 16'h0000, 16'h0012, 64'h0000000000000000)); // ld        a,$23
        testvectors.push_back(cons_test(32'hed570000, 16'h0700, 16'hbeef, 16'h0000, 16'h0000, 16'h0014, 64'h0000000000000000)); // ld        a,i
        testvectors.push_back(cons_test(32'hdd213713, 16'h0700, 16'hbeef, 16'h1337, 16'h0000, 16'h0018, 64'h0000000000000000)); // ld        ix,$1337
        testvectors.push_back(cons_test(32'hfd210190, 16'h0700, 16'hbeef, 16'h1337, 16'h0000, 16'h001C, 64'h0000000000000000)); // ld        iy,$9001
        testvectors.push_back(cons_test(32'hfdf90000, 16'h0700, 16'hbeef, 16'h1337, 16'h9001, 16'h001E, 64'h0000000000000000)); // ld        sp,iy
        testvectors.push_back(cons_test(32'hddf90000, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0020, 64'h0000000000000000)); // ld        sp,ix
        testvectors.push_back(cons_test(32'h11341200, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0023, 64'h0000000000000000)); // ld        de,$1234
        testvectors.push_back(cons_test(32'h21785600, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0026, 64'h0000000000000000)); // ld        hl,$5678
        testvectors.push_back(cons_test(32'heb000000, 16'h0700, 16'hbeef, 16'h1337, 16'h1337, 16'h0027, 64'h0000000000000000)); // ex        de,hl
        testvectors.push_back(cons_test(32'h7a000000, 16'h5600, 16'hbeef, 16'h1337, 16'h1337, 16'h0028, 64'h0000000000000000)); // ld        a,d
        testvectors.push_back(cons_test(32'h7c000000, 16'h1200, 16'hbeef, 16'h1337, 16'h1337, 16'h0029, 64'h0000000000000000)); // ld        a,h
        testvectors.push_back(cons_test(32'h21998800, 16'h1200, 16'hbeef, 16'h1337, 16'h1337, 16'h002C, 64'h0000000000000000)); // ld        hl,$8899
        testvectors.push_back(cons_test(32'hf9000000, 16'h1200, 16'hbeef, 16'h1337, 16'h8899, 16'h002D, 64'h0000000000000000)); // ld        sp,hl
        testvectors.push_back(cons_test(32'h80000000, 16'hd090, 16'hbeef, 16'h1337, 16'h8899, 16'h002E, 64'h0000000000000000)); // add       b
        testvectors.push_back(cons_test(32'hd6010000, 16'hcf92, 16'hbeef, 16'h1337, 16'h8899, 16'h0030, 64'h0000000000000000)); // sub       $01
        testvectors.push_back(cons_test(32'hb0000000, 16'hff80, 16'hbeef, 16'h1337, 16'h8899, 16'h0031, 64'h0000000000000000)); // or        b
        testvectors.push_back(cons_test(32'hc34d0000, 16'hff80, 16'hbeef, 16'h1337, 16'h8899, 16'h004d, 64'h0000000000000000)); // JP        $4d
        testvectors.push_back(cons_test(32'h00000000, 16'hff80, 16'hbeef, 16'h1337, 16'h8899, 16'h004e, 64'h0000000000000000)); // NOP
        testvectors.push_back(cons_test(32'h31100000, 16'hff80, 16'hbeef, 16'h1337, 16'h0010, 16'h0051, 64'h0000000000000000)); // ld        sp,$0010
        testvectors.push_back(cons_test(32'hf5000000, 16'hff80, 16'hbeef, 16'h1337, 16'h000e, 16'h0052, 64'h00000000000080ff)); // push      af
        testvectors.push_back(cons_test(32'hdde50000, 16'hff80, 16'hbeef, 16'h1337, 16'h000c, 16'h0054, 64'h00000000371380ff)); // push      ix
        testvectors.push_back(cons_test(32'hfde50000, 16'hff80, 16'hbeef, 16'h1337, 16'h000a, 16'h0056, 64'h00000190371380ff)); // push      iy
        testvectors.push_back(cons_test(32'hdde10000, 16'hff80, 16'hbeef, 16'h9001, 16'h000c, 16'h0058, 64'h00000190371380ff)); // pop       ix
        testvectors.push_back(cons_test(32'hfde10000, 16'hff80, 16'hbeef, 16'h9001, 16'h000e, 16'h005a, 64'h00000190371380ff)); // pop       iy
        testvectors.push_back(cons_test(32'hc1000000, 16'hff80, 16'hff80, 16'h9001, 16'h0010, 16'h005b, 64'h00000190371380ff)); // pop       bc
        testvectors.push_back(cons_test(32'h21040000, 16'hff80, 16'hff80, 16'h9001, 16'h0010, 16'h005e, 64'h00000190371380ff)); // ld        hl,$0004
        testvectors.push_back(cons_test(32'hdd210100, 16'hff80, 16'hff80, 16'h0001, 16'h0010, 16'h0062, 64'h00000190371380ff)); // ld        ix,$0001
        testvectors.push_back(cons_test(32'hfd210200, 16'hff80, 16'hff80, 16'h0001, 16'h0010, 16'h0066, 64'h00000190371380ff)); // ld        iy,$0002
        testvectors.push_back(cons_test(32'h34000000, 16'hff80, 16'hff80, 16'h0001, 16'h0010, 16'h0067, 64'h00000190381380ff)); // inc       (hl)
        testvectors.push_back(cons_test(32'hdd340b00, 16'hff80, 16'hff80, 16'h0001, 16'h0010, 16'h006a, 64'h00000190391380ff)); // inc       (ix+$0b)
        testvectors.push_back(cons_test(32'hfd340a00, 16'hff80, 16'hff80, 16'h0001, 16'h0010, 16'h006d, 64'h000001903a1380ff)); // inc       (iy+$0a)
        testvectors.push_back(cons_test(32'h7e000000, 16'h3a80, 16'hff80, 16'h0001, 16'h0010, 16'h006e, 64'h000001903a1380ff)); // ld        a,(hl)
        testvectors.push_back(cons_test(32'hdd7e0100, 16'h0180, 16'hff80, 16'h0001, 16'h0010, 16'h0071, 64'h000001903a1380ff)); // ld        a,(ix+$01)
        testvectors.push_back(cons_test(32'hfd7e0200, 16'h3a80, 16'hff80, 16'h0001, 16'h0010, 16'h0074, 64'h000001903a1380ff)); // ld        a,(iy+$02)
        testvectors.push_back(cons_test(32'h01020000, 16'h3a80, 16'h0002, 16'h0001, 16'h0010, 16'h0077, 64'h000001903a1380ff)); // ld        bc,$0002
        testvectors.push_back(cons_test(32'h11030000, 16'h3a80, 16'h0002, 16'h0001, 16'h0010, 16'h007a, 64'h000001903a1380ff)); // ld        de,$0003
        testvectors.push_back(cons_test(32'h0a000000, 16'h0180, 16'h0002, 16'h0001, 16'h0010, 16'h007b, 64'h000001903a1380ff)); // ld        a,(bc)
        testvectors.push_back(cons_test(32'h1a000000, 16'h9080, 16'h0002, 16'h0001, 16'h0010, 16'h007c, 64'h000001903a1380ff)); // ld        a,(de)
        testvectors.push_back(cons_test(32'h3e000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h007e, 64'h000001903a1380ff)); // ld        a,$00
        testvectors.push_back(cons_test(32'h77000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h007f, 64'h00000190001380ff)); // ld        (hl),a
        testvectors.push_back(cons_test(32'hdd770400, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0082, 64'h00000190000080ff)); // ld        (ix+$04),a
        testvectors.push_back(cons_test(32'hfd770500, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0085, 64'h0000019000008000)); // ld        (iy+$05),a
        testvectors.push_back(cons_test(32'h02000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0086, 64'h0000009000008000)); // ld        (bc),a
        testvectors.push_back(cons_test(32'h12000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0087, 64'h0000000000008000)); // ld        (de),a
        testvectors.push_back(cons_test(32'h36080000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0089, 64'h0000000008008000)); // ld        (hl),$08
        testvectors.push_back(cons_test(32'hdd360409, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h008d, 64'h0000000008098000)); // ld        (ix+$04),$09
        testvectors.push_back(cons_test(32'hfd360107, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0091, 64'h0000000708098000)); // ld        (iy+$01),$07
        testvectors.push_back(cons_test(32'hca000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0094, 64'h0000000708098000)); // JP        z,0
        testvectors.push_back(cons_test(32'hc2111000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h1011, 64'h0000000708098000)); // JP        nz,$1011
        testvectors.push_back(cons_test(32'h18cc0000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0fdf, 64'h0000000708098000)); // JR        -50
        testvectors.push_back(cons_test(32'h18740000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h1055, 64'h0000000708098000)); // JR        $76
        testvectors.push_back(cons_test(32'h28030000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h1057, 64'h0000000708098000)); // JR        z,5
        testvectors.push_back(cons_test(32'h20980000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0ff1, 64'h0000000708098000)); // JR        nz,-102
        testvectors.push_back(cons_test(32'h21adde00, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'h0ff4, 64'h0000000708098000)); // ld        hl,$dead
        testvectors.push_back(cons_test(32'he9000000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'hdead, 64'h0000000708098000)); // jp        (hl)
        testvectors.push_back(cons_test(32'h06ff0000, 16'h0080, 16'hff02, 16'h0001, 16'h0010, 16'hdeaf, 64'h0000000708098000)); // ld        b,$ff
        testvectors.push_back(cons_test(32'h10fd0000, 16'h0080, 16'hfe02, 16'h0001, 16'h0010, 16'hdeae, 64'h0000000708098000)); // djnz      -1
        testvectors.push_back(cons_test(32'h06010000, 16'h0080, 16'h0102, 16'h0001, 16'h0010, 16'hdeb0, 64'h0000000708098000)); // ld        b,1
        testvectors.push_back(cons_test(32'h10fd0000, 16'h0080, 16'h0002, 16'h0001, 16'h0010, 16'hdeb2, 64'h0000000708098000)); // djnz      -1
        testvectors.push_back(cons_test(32'h3e090000, 16'h0980, 16'h0002, 16'h0001, 16'h0010, 16'hdeb4, 64'h0000000708098000)); // ld        a,$09
        testvectors.push_back(cons_test(32'h1e050000, 16'h0980, 16'h0002, 16'h0001, 16'h0010, 16'hdeb6, 64'h0000000708098000)); // ld        e,$05
        testvectors.push_back(cons_test(32'h9b000000, 16'h0402, 16'h0002, 16'h0001, 16'h0010, 16'hdeb7, 64'h0000000708098000)); // sbc       e
        testvectors.push_back(cons_test(32'h9b000000, 16'hff93, 16'h0002, 16'h0001, 16'h0010, 16'hdeb8, 64'h0000000708098000)); // sbc       e
        testvectors.push_back(cons_test(32'h3e070000, 16'h0793, 16'h0002, 16'h0001, 16'h0010, 16'hdeba, 64'h0000000708098000)); // ld        a,$07
        testvectors.push_back(cons_test(32'h9b000000, 16'h0102, 16'h0002, 16'h0001, 16'h0010, 16'hdebb, 64'h0000000708098000)); // sbc       e
        testvectors.push_back(cons_test(32'h3e020000, 16'h0202, 16'h0002, 16'h0001, 16'h0010, 16'hdebd, 64'h0000000708098000)); // ld        a,$02
        testvectors.push_back(cons_test(32'hbb000000, 16'h0293, 16'h0002, 16'h0001, 16'h0010, 16'hdebe, 64'h0000000708098000)); // cp        e
        testvectors.push_back(cons_test(32'h3eff0000, 16'hff93, 16'h0002, 16'h0001, 16'h0010, 16'hdec0, 64'h0000000708098000)); // ld        a,$ff
        testvectors.push_back(cons_test(32'hbb000000, 16'hff82, 16'h0002, 16'h0001, 16'h0010, 16'hdec1, 64'h0000000708098000)); // cp        e
        testvectors.push_back(cons_test(32'h37000000, 16'hff81, 16'h0002, 16'h0001, 16'h0010, 16'hdec2, 64'h0000000708098000)); // scf
        testvectors.push_back(cons_test(32'h3f000000, 16'hff90, 16'h0002, 16'h0001, 16'h0010, 16'hdec3, 64'h0000000708098000)); // ccf
        testvectors.push_back(cons_test(32'h3f000000, 16'hff81, 16'h0002, 16'h0001, 16'h0010, 16'hdec4, 64'h0000000708098000)); // ccf
        testvectors.push_back(cons_reset()); /* the call instruction group */
        testvectors.push_back(cons_test(32'hc3efbe00, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'hbeef, 64'h0000000000000000)); // JP        $4d
        testvectors.push_back(cons_test(32'h31100000, 16'h0000, 16'h0000, 16'h0000, 16'h0010, 16'hbef2, 64'h0000000000000000)); // ld        sp,$0010
        testvectors.push_back(cons_test(32'hcd371300, 16'h0000, 16'h0000, 16'h0000, 16'h000e, 16'h1337, 64'h000000000000f5be)); // call      1337
        testvectors.push_back(cons_test(32'hdc777700, 16'h0000, 16'h0000, 16'h0000, 16'h000e, 16'h133a, 64'h000000000000f5be)); // call      c,$7777
        testvectors.push_back(cons_test(32'hd4888800, 16'h0000, 16'h0000, 16'h0000, 16'h000c, 16'h8888, 64'h000000003d13f5be)); // call      c,$7777
        testvectors.push_back(cons_test(32'hc9000000, 16'h0000, 16'h0000, 16'h0000, 16'h000e, 16'h133d, 64'h000000003d13f5be)); // ret
        testvectors.push_back(cons_test(32'he8000000, 16'h0000, 16'h0000, 16'h0000, 16'h000e, 16'h133e, 64'h000000003d13f5be)); // ret       pe
        testvectors.push_back(cons_test(32'he0000000, 16'h0000, 16'h0000, 16'h0000, 16'h0010, 16'hbef5, 64'h000000003d13f5be)); // ret       po
        testvectors.push_back(cons_reset()); /* testing the halt instructions */
        testvectors.push_back(cons_test(32'hc34d0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h004d, 64'h0000000000000000)); // JP        $4d
        testvectors.push_back(cons_test(32'h76000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h004d, 64'h0000000000000000)); // HALT
        testvectors.push_back(cons_test(32'h76000000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h004d, 64'h0000000000000000)); // HALT
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'h3e670000, 16'h6700, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // ld        a,$67
        testvectors.push_back(cons_test(32'h32010000, 16'h6700, 16'h0000, 16'h0000, 16'h0000, 16'h0006, 64'h0067000000000000)); // ld        ($0001),a
        testvectors.push_back(cons_test(32'h01341200, 16'h6700, 16'h1234, 16'h0000, 16'h0000, 16'h0009, 64'h0067000000000000)); // ld        bc,$1234
        testvectors.push_back(cons_test(32'hed430200, 16'h6700, 16'h1234, 16'h0000, 16'h0000, 16'h000d, 64'h0067341200000000)); // ld        ($0002),bc
        testvectors.push_back(cons_test(32'h08000000, 16'h0000, 16'h1234, 16'h0000, 16'h0000, 16'h000e, 64'h0067341200000000)); // ex        af,af'
        testvectors.push_back(cons_test(32'h3e210000, 16'h2100, 16'h1234, 16'h0000, 16'h0000, 16'h0010, 64'h0067341200000000)); // ld        a,$21
        testvectors.push_back(cons_test(32'h08000000, 16'h6700, 16'h1234, 16'h0000, 16'h0000, 16'h0011, 64'h0067341200000000)); // ex        af,af'
        testvectors.push_back(cons_test(32'hd9000000, 16'h2100, 16'h0000, 16'h0000, 16'h0000, 16'h0012, 64'h0067341200000000)); // exx
        testvectors.push_back(cons_test(32'h3a020000, 16'h3400, 16'h0000, 16'h0000, 16'h0000, 16'h0015, 64'h0067341200000000)); // ld        a,($0002)
        testvectors.push_back(cons_test(32'h21896700, 16'h3400, 16'h0000, 16'h0000, 16'h0000, 16'h0018, 64'h0067341200000000)); // ld        hl,$6789
        testvectors.push_back(cons_test(32'hdd213254, 16'h3400, 16'h0000, 16'h5432, 16'h0000, 16'h001c, 64'h0067341200000000)); // ld        ix,$5432
        testvectors.push_back(cons_test(32'hfd214523, 16'h3400, 16'h0000, 16'h5432, 16'h0000, 16'h0020, 64'h0067341200000000)); // ld        iy,$2345
        testvectors.push_back(cons_test(32'h31040000, 16'h3400, 16'h0000, 16'h5432, 16'h0004, 16'h0023, 64'h0067341200000000)); // ld        sp,$0004
        testvectors.push_back(cons_test(32'he3000000, 16'h3400, 16'h0000, 16'h5432, 16'h0004, 16'h0024, 64'h0067341289670000)); // ex        (sp),hl
        testvectors.push_back(cons_test(32'hdde30000, 16'h3400, 16'h0000, 16'h6789, 16'h0004, 16'h0026, 64'h0067341232540000)); // ex        (sp),ix
        testvectors.push_back(cons_test(32'hfde30000, 16'h3400, 16'h0000, 16'h6789, 16'h0004, 16'h0028, 64'h0067341245230000)); // ex        (sp),iy
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'h3e080000, 16'h0800, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // ld        a,$08
        testvectors.push_back(cons_test(32'h1e020000, 16'h0800, 16'h0000, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000)); // ld        e,$02
        testvectors.push_back(cons_test(32'h21070000, 16'h0800, 16'h0000, 16'h0000, 16'h0000, 16'h0008, 64'h0000000000000000)); // ld        hl,$0007
        testvectors.push_back(cons_test(32'hdd210600, 16'h0800, 16'h0000, 16'h0006, 16'h0000, 16'h000c, 64'h0000000000000000)); // ld        ix,$0006
        testvectors.push_back(cons_test(32'hfd210500, 16'h0800, 16'h0000, 16'h0006, 16'h0000, 16'h0010, 64'h0000000000000000)); // ld        iy,$0005
        testvectors.push_back(cons_test(32'h36100000, 16'h0800, 16'h0000, 16'h0006, 16'h0000, 16'h0012, 64'h0000000000000010)); // ld        (hl),$10
        testvectors.push_back(cons_test(32'hdd360011, 16'h0800, 16'h0000, 16'h0006, 16'h0000, 16'h0016, 64'h0000000000001110)); // ld        (ix+$00),$11
        testvectors.push_back(cons_test(32'hfd360033, 16'h0800, 16'h0000, 16'h0006, 16'h0000, 16'h001a, 64'h0000000000331110)); // ld        (iy+$00),$33
        testvectors.push_back(cons_test(32'h83000000, 16'h0a00, 16'h0000, 16'h0006, 16'h0000, 16'h001b, 64'h0000000000331110)); // add       e
        testvectors.push_back(cons_test(32'hc6010000, 16'h0b00, 16'h0000, 16'h0006, 16'h0000, 16'h001d, 64'h0000000000331110)); // add       $01
        testvectors.push_back(cons_test(32'h86000000, 16'h1b00, 16'h0000, 16'h0006, 16'h0000, 16'h001e, 64'h0000000000331110)); // add       (hl)
        testvectors.push_back(cons_test(32'hdd860100, 16'h2b00, 16'h0000, 16'h0006, 16'h0000, 16'h0021, 64'h0000000000331110)); // add       (ix+$01)
        testvectors.push_back(cons_test(32'hfd860200, 16'h3b00, 16'h0000, 16'h0006, 16'h0000, 16'h0024, 64'h0000000000331110)); // add       (iy+$02)
        testvectors.push_back(cons_test(32'h8b000000, 16'h3d00, 16'h0000, 16'h0006, 16'h0000, 16'h0025, 64'h0000000000331110)); // adc       e
        testvectors.push_back(cons_test(32'hce010000, 16'h3e00, 16'h0000, 16'h0006, 16'h0000, 16'h0027, 64'h0000000000331110)); // adc       $01
        testvectors.push_back(cons_test(32'h8e000000, 16'h4e00, 16'h0000, 16'h0006, 16'h0000, 16'h0028, 64'h0000000000331110)); // adc       (hl)
        testvectors.push_back(cons_test(32'hdd8e0100, 16'h5e00, 16'h0000, 16'h0006, 16'h0000, 16'h002b, 64'h0000000000331110)); // adc       (ix+$01)
        testvectors.push_back(cons_test(32'hfd8e0200, 16'h6e00, 16'h0000, 16'h0006, 16'h0000, 16'h002e, 64'h0000000000331110)); // adc       (iy+$02)
        testvectors.push_back(cons_test(32'h37000000, 16'h6e01, 16'h0000, 16'h0006, 16'h0000, 16'h002f, 64'h0000000000331110)); // scf
        testvectors.push_back(cons_test(32'h8b000000, 16'h7110, 16'h0000, 16'h0006, 16'h0000, 16'h0030, 64'h0000000000331110)); // adc       e
        testvectors.push_back(cons_test(32'h93000000, 16'h6f12, 16'h0000, 16'h0006, 16'h0000, 16'h0031, 64'h0000000000331110)); // sub       e
        testvectors.push_back(cons_test(32'hd6010000, 16'h6e02, 16'h0000, 16'h0006, 16'h0000, 16'h0033, 64'h0000000000331110)); // sub       $01
        testvectors.push_back(cons_test(32'h96000000, 16'h5e02, 16'h0000, 16'h0006, 16'h0000, 16'h0034, 64'h0000000000331110)); // sub       (hl)
        testvectors.push_back(cons_test(32'hdd960100, 16'h4e02, 16'h0000, 16'h0006, 16'h0000, 16'h0037, 64'h0000000000331110)); // sub       (ix+$01)
        testvectors.push_back(cons_test(32'hfd960200, 16'h3e02, 16'h0000, 16'h0006, 16'h0000, 16'h003a, 64'h0000000000331110)); // sub       (iy+$02)
        testvectors.push_back(cons_test(32'h9b000000, 16'h3c02, 16'h0000, 16'h0006, 16'h0000, 16'h003b, 64'h0000000000331110)); // sbc       e
        testvectors.push_back(cons_test(32'hde010000, 16'h3b02, 16'h0000, 16'h0006, 16'h0000, 16'h003d, 64'h0000000000331110)); // sbc       $01
        testvectors.push_back(cons_test(32'h9e000000, 16'h2b02, 16'h0000, 16'h0006, 16'h0000, 16'h003e, 64'h0000000000331110)); // sbc       (hl)
        testvectors.push_back(cons_test(32'hdd9e0100, 16'h1b02, 16'h0000, 16'h0006, 16'h0000, 16'h0041, 64'h0000000000331110)); // sbc       (ix+$01)
        testvectors.push_back(cons_test(32'hfd9e0200, 16'h0b02, 16'h0000, 16'h0006, 16'h0000, 16'h0044, 64'h0000000000331110)); // sbc       (iy+$02)
        testvectors.push_back(cons_test(32'h3f000000, 16'h0b03, 16'h0000, 16'h0006, 16'h0000, 16'h0045, 64'h0000000000331110)); // ccf
        testvectors.push_back(cons_test(32'h9b000000, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0046, 64'h0000000000331110)); // sbc       e
        testvectors.push_back(cons_test(32'h3c000000, 16'h0900, 16'h0000, 16'h0006, 16'h0000, 16'h0047, 64'h0000000000331110)); // inc       a
        testvectors.push_back(cons_test(32'h3d000000, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0048, 64'h0000000000331110)); // dec       a
        testvectors.push_back(cons_test(32'h34000000, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0049, 64'h0000000000331111)); // inc       (hl)
        testvectors.push_back(cons_test(32'hdd340100, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h004c, 64'h0000000000331112)); // inc       (ix+$01)
        testvectors.push_back(cons_test(32'hfd340200, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h004f, 64'h0000000000331113)); // inc       (iy+$02)
        testvectors.push_back(cons_test(32'h35000000, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0050, 64'h0000000000331112)); // dec       (hl)
        testvectors.push_back(cons_test(32'hdd350100, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0053, 64'h0000000000331111)); // dec       (ix+$01)
        testvectors.push_back(cons_test(32'hfd350200, 16'h0802, 16'h0000, 16'h0006, 16'h0000, 16'h0056, 64'h0000000000331110)); // dec       (iy+$02)
        testvectors.push_back(cons_test(32'ha3000000, 16'h0050, 16'h0000, 16'h0006, 16'h0000, 16'h0057, 64'h0000000000331110)); // and       e
        testvectors.push_back(cons_test(32'he6010000, 16'h0050, 16'h0000, 16'h0006, 16'h0000, 16'h0059, 64'h0000000000331110)); // and       $01
        testvectors.push_back(cons_test(32'h3eff0000, 16'hff50, 16'h0000, 16'h0006, 16'h0000, 16'h005b, 64'h0000000000331110)); // ld        a,$ff
        testvectors.push_back(cons_test(32'hfda60000, 16'h3310, 16'h0000, 16'h0006, 16'h0000, 16'h005e, 64'h0000000000331110)); // and       (iy+$00)
        testvectors.push_back(cons_test(32'hdda60000, 16'h1110, 16'h0000, 16'h0006, 16'h0000, 16'h0061, 64'h0000000000331110)); // and       (ix+$00)
        testvectors.push_back(cons_test(32'ha6000000, 16'h1010, 16'h0000, 16'h0006, 16'h0000, 16'h0062, 64'h0000000000331110)); // and       (hl)
        testvectors.push_back(cons_test(32'hb3000000, 16'h1200, 16'h0000, 16'h0006, 16'h0000, 16'h0063, 64'h0000000000331110)); // or        e
        testvectors.push_back(cons_test(32'hf6010000, 16'h1300, 16'h0000, 16'h0006, 16'h0000, 16'h0065, 64'h0000000000331110)); // or        $01
        testvectors.push_back(cons_test(32'hb6000000, 16'h1300, 16'h0000, 16'h0006, 16'h0000, 16'h0066, 64'h0000000000331110)); // or        (hl)
        testvectors.push_back(cons_test(32'hfdb60000, 16'h3300, 16'h0000, 16'h0006, 16'h0000, 16'h0069, 64'h0000000000331110)); // or        (iy+$00)
        testvectors.push_back(cons_test(32'hddb60000, 16'h3300, 16'h0000, 16'h0006, 16'h0000, 16'h006c, 64'h0000000000331110)); // or        (ix+$00)
        testvectors.push_back(cons_test(32'hab000000, 16'h3100, 16'h0000, 16'h0006, 16'h0000, 16'h006d, 64'h0000000000331110)); // xor       e
        testvectors.push_back(cons_test(32'hee010000, 16'h3004, 16'h0000, 16'h0006, 16'h0000, 16'h006f, 64'h0000000000331110)); // xor       $01
        testvectors.push_back(cons_test(32'hae000000, 16'h2000, 16'h0000, 16'h0006, 16'h0000, 16'h0070, 64'h0000000000331110)); // xor       (hl)
        testvectors.push_back(cons_test(32'hfdae0000, 16'h1300, 16'h0000, 16'h0006, 16'h0000, 16'h0073, 64'h0000000000331110)); // xor       (iy+$00)
        testvectors.push_back(cons_test(32'hddae0000, 16'h0200, 16'h0000, 16'h0006, 16'h0000, 16'h0076, 64'h0000000000331110)); // xor       (ix+$00)
        testvectors.push_back(cons_test(32'h3e100000, 16'h1000, 16'h0000, 16'h0006, 16'h0000, 16'h0078, 64'h0000000000331110)); // ld        a,$10
        testvectors.push_back(cons_test(32'hbb000000, 16'h1012, 16'h0000, 16'h0006, 16'h0000, 16'h0079, 64'h0000000000331110)); // cp        e
        testvectors.push_back(cons_test(32'hfe010000, 16'h1012, 16'h0000, 16'h0006, 16'h0000, 16'h007b, 64'h0000000000331110)); // cp        $01
        testvectors.push_back(cons_test(32'hbe000000, 16'h1042, 16'h0000, 16'h0006, 16'h0000, 16'h007c, 64'h0000000000331110)); // cp        (hl)
        testvectors.push_back(cons_test(32'hfdbe0000, 16'h1093, 16'h0000, 16'h0006, 16'h0000, 16'h007f, 64'h0000000000331110)); // cp        (iy+$00)
        testvectors.push_back(cons_test(32'hddbe0000, 16'h1093, 16'h0000, 16'h0006, 16'h0000, 16'h0082, 64'h0000000000331110)); // cp        (ix+$00)
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'h3e0f0000, 16'h0f00, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // ld        a,$0f
        testvectors.push_back(cons_test(32'h2f080000, 16'hf012, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // cpl
        testvectors.push_back(cons_test(32'h3e020000, 16'h0212, 16'h0000, 16'h0000, 16'h0000, 16'h0006, 64'h0000000000000000)); // ld        a,$02
        testvectors.push_back(cons_test(32'hed440000, 16'hfe93, 16'h0000, 16'h0000, 16'h0000, 16'h0008, 64'h0000000000000000)); // neg
        // just to make sure the states sequense correctly and the instruction is decoded. no idea if the result is correct
        testvectors.push_back(cons_test(32'h27000000, 16'h9883, 16'h0000, 16'h0000, 16'h0000, 16'h0009, 64'h0000000000000000)); // daa 
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'h21021200, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // ld        hl,$1202
        testvectors.push_back(cons_test(32'h01010100, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h0007, 64'h0000000000000000)); // ld        bc,$0101
        testvectors.push_back(cons_test(32'h09000000, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h0008, 64'h0000000000000000)); // add       hl,bc
        testvectors.push_back(cons_test(32'h22000000, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h000b, 64'h0313000000000000)); // ld        ($0000),hl
        testvectors.push_back(cons_test(32'hfd090000, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h000d, 64'h0313000000000000)); // add       iy,bc
        testvectors.push_back(cons_test(32'hfd230000, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h000f, 64'h0313000000000000)); // inc       iy
        testvectors.push_back(cons_test(32'hfd220000, 16'h0000, 16'h0101, 16'h0000, 16'h0000, 16'h0013, 64'h0201000000000000)); // ld        ($0000),iy
        testvectors.push_back(cons_test(32'hdd090000, 16'h0000, 16'h0101, 16'h0101, 16'h0000, 16'h0015, 64'h0201000000000000)); // add       ix,bc
        testvectors.push_back(cons_test(32'hed4a0000, 16'h0000, 16'h0101, 16'h0101, 16'h0000, 16'h0017, 64'h0201000000000000)); // adc       hl,bc
        testvectors.push_back(cons_test(32'h22000000, 16'h0000, 16'h0101, 16'h0101, 16'h0000, 16'h001a, 64'h0414000000000000)); // ld        ($0000),hl
        testvectors.push_back(cons_test(32'h3f000000, 16'h0001, 16'h0101, 16'h0101, 16'h0000, 16'h001b, 64'h0414000000000000)); // ccf
        testvectors.push_back(cons_test(32'hed4a0000, 16'h0000, 16'h0101, 16'h0101, 16'h0000, 16'h001d, 64'h0414000000000000)); // adc       hl,bc
        testvectors.push_back(cons_test(32'h22000000, 16'h0000, 16'h0101, 16'h0101, 16'h0000, 16'h0020, 64'h0615000000000000)); // ld        ($0000),hl
        testvectors.push_back(cons_test(32'h3f000000, 16'h0001, 16'h0101, 16'h0101, 16'h0000, 16'h0021, 64'h0615000000000000)); // ccf
        testvectors.push_back(cons_test(32'hed520000, 16'h0002, 16'h0101, 16'h0101, 16'h0000, 16'h0023, 64'h0615000000000000)); // sbc       hl,de
        testvectors.push_back(cons_test(32'h22000000, 16'h0002, 16'h0101, 16'h0101, 16'h0000, 16'h0026, 64'h0515000000000000)); // ld        ($0000),hl
        testvectors.push_back(cons_test(32'h03000000, 16'h0002, 16'h0102, 16'h0101, 16'h0000, 16'h0027, 64'h0515000000000000)); // inc       bc
        testvectors.push_back(cons_test(32'hdd230000, 16'h0002, 16'h0102, 16'h0102, 16'h0000, 16'h0029, 64'h0515000000000000)); // inc       ix
        testvectors.push_back(cons_test(32'hdd2b0000, 16'h0002, 16'h0102, 16'h0101, 16'h0000, 16'h002b, 64'h0515000000000000)); // dec       ix
        testvectors.push_back(cons_test(32'hfd2b0000, 16'h0002, 16'h0102, 16'h0101, 16'h0000, 16'h002d, 64'h0515000000000000)); // dec       iy
        testvectors.push_back(cons_test(32'hfd220000, 16'h0002, 16'h0102, 16'h0101, 16'h0000, 16'h0031, 64'h0101000000000000)); // ld        ($0000),iy
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'h3e800000, 16'h8000, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // ld        a,$80
        testvectors.push_back(cons_test(32'h07000000, 16'h0101, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // rlca
        testvectors.push_back(cons_test(32'h17000000, 16'h0300, 16'h0000, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000)); // rla
        testvectors.push_back(cons_test(32'h0f000000, 16'h8101, 16'h0000, 16'h0000, 16'h0000, 16'h0006, 64'h0000000000000000)); // rrca
        testvectors.push_back(cons_test(32'h1f000000, 16'hc001, 16'h0000, 16'h0000, 16'h0000, 16'h0007, 64'h0000000000000000)); // rra
        testvectors.push_back(cons_test(32'h06800000, 16'hc001, 16'h8000, 16'h0000, 16'h0000, 16'h0009, 64'h0000000000000000)); // ld        b,$80
        testvectors.push_back(cons_test(32'hcb000000, 16'hc001, 16'h0100, 16'h0000, 16'h0000, 16'h000b, 64'h0000000000000000)); // rlc       b
        testvectors.push_back(cons_test(32'hcb100000, 16'hc004, 16'h0300, 16'h0000, 16'h0000, 16'h000d, 64'h0000000000000000)); // rl        b
        testvectors.push_back(cons_test(32'hcb080000, 16'hc085, 16'h8100, 16'h0000, 16'h0000, 16'h000f, 64'h0000000000000000)); // rrc       b
        testvectors.push_back(cons_test(32'hcb180000, 16'hc085, 16'hc000, 16'h0000, 16'h0000, 16'h0011, 64'h0000000000000000)); // rr        b
        testvectors.push_back(cons_test(32'h06800000, 16'hc085, 16'h8000, 16'h0000, 16'h0000, 16'h0013, 64'h0000000000000000)); // ld        b,$80
        testvectors.push_back(cons_test(32'hcb200000, 16'hc045, 16'h0000, 16'h0000, 16'h0000, 16'h0015, 64'h0000000000000000)); // sla       b
        testvectors.push_back(cons_test(32'h06800000, 16'hc045, 16'h8000, 16'h0000, 16'h0000, 16'h0017, 64'h0000000000000000)); // ld        b,$80
        testvectors.push_back(cons_test(32'hcb280000, 16'hc084, 16'hc000, 16'h0000, 16'h0000, 16'h0019, 64'h0000000000000000)); // sra       b
        testvectors.push_back(cons_test(32'h06810000, 16'hc084, 16'h8100, 16'h0000, 16'h0000, 16'h001b, 64'h0000000000000000)); // ld        b,$81
        testvectors.push_back(cons_test(32'hcb280000, 16'hc085, 16'hc000, 16'h0000, 16'h0000, 16'h001d, 64'h0000000000000000)); // sra       b
        testvectors.push_back(cons_test(32'h06800000, 16'hc085, 16'h8000, 16'h0000, 16'h0000, 16'h001f, 64'h0000000000000000)); // ld        b,$80
        testvectors.push_back(cons_test(32'hcb380000, 16'hc000, 16'h4000, 16'h0000, 16'h0000, 16'h0021, 64'h0000000000000000)); // srl       b
        testvectors.push_back(cons_test(32'h06810000, 16'hc000, 16'h8100, 16'h0000, 16'h0000, 16'h0023, 64'h0000000000000000)); // ld        b,$81
        testvectors.push_back(cons_test(32'hcb380000, 16'hc001, 16'h4000, 16'h0000, 16'h0000, 16'h0025, 64'h0000000000000000)); // srl       b
        testvectors.push_back(cons_test(32'h21070000, 16'hc001, 16'h4000, 16'h0000, 16'h0000, 16'h0028, 64'h0000000000000000)); // ld        hl,$0007
        testvectors.push_back(cons_test(32'hdd210600, 16'hc001, 16'h4000, 16'h0006, 16'h0000, 16'h002c, 64'h0000000000000000)); // ld        ix,$0006
        testvectors.push_back(cons_test(32'hfd210500, 16'hc001, 16'h4000, 16'h0006, 16'h0000, 16'h0030, 64'h0000000000000000)); // ld        iy,$0005
        testvectors.push_back(cons_test(32'h36010000, 16'hc001, 16'h4000, 16'h0006, 16'h0000, 16'h0032, 64'h0000000000000001)); // ld        (hl),$01
        testvectors.push_back(cons_test(32'hcb060000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0034, 64'h0000000000000002)); // rlc       (hl)
        testvectors.push_back(cons_test(32'hddcb0106, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0038, 64'h0000000000000004)); // rlc       (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb0206, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h003c, 64'h0000000000000008)); // rlc       (iy+$02)
        testvectors.push_back(cons_test(32'hcb160000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h003e, 64'h0000000000000010)); // rl        (hl)
        testvectors.push_back(cons_test(32'hddcb0116, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0042, 64'h0000000000000020)); // rl        (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb0216, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0046, 64'h0000000000000040)); // rl        (iy+$02)
        testvectors.push_back(cons_test(32'hcb0e0000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0048, 64'h0000000000000020)); // rrc       (hl)
        testvectors.push_back(cons_test(32'hddcb010e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h004c, 64'h0000000000000010)); // rrc       (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb020e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0050, 64'h0000000000000008)); // rrc       (iy+$02)
        testvectors.push_back(cons_test(32'hcb1e0000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0052, 64'h0000000000000004)); // rr        (hl)
        testvectors.push_back(cons_test(32'hddcb011e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0056, 64'h0000000000000002)); // rr        (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb021e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h005a, 64'h0000000000000001)); // rr        (iy+$02)
        testvectors.push_back(cons_test(32'hcb260000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h005c, 64'h0000000000000002)); // sla       (hl)
        testvectors.push_back(cons_test(32'hddcb0126, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0060, 64'h0000000000000004)); // sla       (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb0226, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0064, 64'h0000000000000008)); // sla       (iy+$02)
        testvectors.push_back(cons_test(32'hcb2e0000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0066, 64'h0000000000000004)); // sra       (hl)
        testvectors.push_back(cons_test(32'hddcb012e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h006a, 64'h0000000000000002)); // sra       (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb022e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h006e, 64'h0000000000000001)); // sra       (iy+$02)
        testvectors.push_back(cons_test(32'hcb260000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0070, 64'h0000000000000002)); // sla       (hl)
        testvectors.push_back(cons_test(32'hcb260000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0072, 64'h0000000000000004)); // sla       (hl)
        testvectors.push_back(cons_test(32'hcb260000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0074, 64'h0000000000000008)); // sla       (hl)
        testvectors.push_back(cons_test(32'hcb3e0000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0076, 64'h0000000000000004)); // srl       (hl)
        testvectors.push_back(cons_test(32'hddcb013e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h007a, 64'h0000000000000002)); // srl       (ix+$01)
        testvectors.push_back(cons_test(32'hfdcb023e, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h007e, 64'h0000000000000001)); // srl       (iy+$02)
        testvectors.push_back(cons_test(32'h21040000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0081, 64'h0000000000000001)); // ld        hl,$0004
        testvectors.push_back(cons_test(32'h36120000, 16'hc000, 16'h4000, 16'h0006, 16'h0000, 16'h0083, 64'h0000000012000001)); // ld        (hl),$12
        testvectors.push_back(cons_test(32'h3e340000, 16'h3400, 16'h4000, 16'h0006, 16'h0000, 16'h0085, 64'h0000000012000001)); // ld        a,$34
        testvectors.push_back(cons_test(32'hed6f0000, 16'h3104, 16'h4000, 16'h0006, 16'h0000, 16'h0087, 64'h0000000024000001)); // rld
        testvectors.push_back(cons_test(32'hed670000, 16'h3404, 16'h4000, 16'h0006, 16'h0000, 16'h0089, 64'h0000000012000001)); // rrd
        testvectors.push_back(cons_reset()); /* the test for the bit instruction group */
        //                              instruction   AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back(cons_test(32'hcb590000, 16'h0050, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // bit       3,c
        testvectors.push_back(cons_test(32'h0e080000, 16'h0050, 16'h0008, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000)); // ld        c,08
        testvectors.push_back(cons_test(32'hcb590000, 16'h0010, 16'h0008, 16'h0000, 16'h0000, 16'h0007, 64'h0000000000000000)); // bit       3,c
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'hddcb0266, 16'h0050, 16'h0000, 16'h0000, 16'h0000, 16'h0005, 64'h0000000000000000)); // bit       4,(ix + 2)
        testvectors.push_back(cons_test(32'hdd360210, 16'h0050, 16'h0000, 16'h0000, 16'h0000, 16'h0009, 64'h0000100000000000)); // ld        (ix + 2),10
        testvectors.push_back(cons_test(32'h3f000000, 16'h0041, 16'h0000, 16'h0000, 16'h0000, 16'h000a, 64'h0000100000000000)); // ccf
        testvectors.push_back(cons_test(32'hddcb0266, 16'h0011, 16'h0000, 16'h0000, 16'h0000, 16'h000e, 64'h0000100000000000)); // bit       4,(ix + 2)
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'hcbf00000, 16'h0000, 16'h4000, 16'h0000, 16'h0000, 16'h0003, 64'h0000000000000000)); // set       6,h
        testvectors.push_back(cons_test(32'hdd210400, 16'h0000, 16'h4000, 16'h0004, 16'h0000, 16'h0007, 64'h0000000000000000)); // ld        ix,$0004
        testvectors.push_back(cons_test(32'hddcb02ee, 16'h0000, 16'h4000, 16'h0004, 16'h0000, 16'h000b, 64'h0000000000002000)); // set       5,(ix + 2)
        testvectors.push_back(cons_test(32'hdd210200, 16'h0000, 16'h4000, 16'h0002, 16'h0000, 16'h000f, 64'h0000000000002000)); // ld        ix,$0002
        testvectors.push_back(cons_test(32'hdd3602ff, 16'h0000, 16'h4000, 16'h0002, 16'h0000, 16'h0013, 64'h00000000ff002000)); // ld        (ix+$02),$ff
        testvectors.push_back(cons_test(32'hddcb0296, 16'h0000, 16'h4000, 16'h0002, 16'h0000, 16'h0017, 64'h00000000fb002000)); // res       2,(ix + 2)
        testvectors.push_back(cons_test(32'h0eff0000, 16'h0000, 16'h40ff, 16'h0002, 16'h0000, 16'h0019, 64'h00000000fb002000)); // ld        c,ff
        testvectors.push_back(cons_test(32'hcb890000, 16'h0000, 16'h40fd, 16'h0002, 16'h0000, 16'h001b, 64'h00000000fb002000)); // res       1,c
        testvectors.push_back(cons_reset());
        testvectors.push_back(cons_test(32'hdd36000a, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0005, 64'h0a00000000000000)); // ld        (ix+$00),$0a
        testvectors.push_back(cons_test(32'hdd36010b, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0009, 64'h0a0b000000000000)); // ld        (ix+$01),$0b
        testvectors.push_back(cons_test(32'hdd36020c, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h000d, 64'h0a0b0c0000000000)); // ld        (ix+$02),$0c
        testvectors.push_back(cons_test(32'hdd36030d, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0011, 64'h0a0b0c0d00000000)); // ld        (ix+$03),$0d
        testvectors.push_back(cons_test(32'h11070000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0014, 64'h0a0b0c0d00000000)); // ld        de,$0007
        testvectors.push_back(cons_test(32'h21030000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0017, 64'h0a0b0c0d00000000)); // ld        hl,$0003
        testvectors.push_back(cons_test(32'heda80000, 16'h0004, 16'h00ff, 16'h0000, 16'h0000, 16'h0019, 64'h0a0b0c0d0000000d)); // ldd
        testvectors.push_back(cons_test(32'heda00000, 16'h0004, 16'h00fe, 16'h0000, 16'h0000, 16'h001b, 64'h0a0b0c0d00000c0d)); // ldi
        testvectors.push_back(cons_test(32'hdd360700, 16'h0004, 16'h00fe, 16'h0000, 16'h0000, 16'h001f, 64'h0a0b0c0d00000c00)); // ld        (ix+$07),$00
        testvectors.push_back(cons_test(32'hdd360600, 16'h0004, 16'h00fe, 16'h0000, 16'h0000, 16'h0023, 64'h0a0b0c0d00000000)); // ld        (ix+$06),$00
        testvectors.push_back(cons_test(32'h01040000, 16'h0004, 16'h0004, 16'h0000, 16'h0000, 16'h0026, 64'h0a0b0c0d00000000)); // ld        bc,$0004
        testvectors.push_back(cons_test(32'hedb80000, 16'h0004, 16'h0003, 16'h0000, 16'h0000, 16'h0026, 64'h0a0b0c0d0000000d)); // lddr
        testvectors.push_back(cons_test(32'hedb80000, 16'h0004, 16'h0002, 16'h0000, 16'h0000, 16'h0026, 64'h0a0b0c0d00000c0d)); // lddr //this is an issue with our tb, in real code lddr should act ok
        testvectors.push_back(cons_test(32'hedb80000, 16'h0004, 16'h0001, 16'h0000, 16'h0000, 16'h0026, 64'h0a0b0c0d000b0c0d)); // lddr
        testvectors.push_back(cons_test(32'hedb80000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0028, 64'h0a0b0c0d0a0b0c0d)); // lddr
        testvectors.push_back(cons_test(32'hdd360700, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h002c, 64'h0a0b0c0d0a0b0c00)); // ld        (ix+$07),$00
        testvectors.push_back(cons_test(32'hdd360600, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0030, 64'h0a0b0c0d0a0b0000)); // ld        (ix+$06),$00
        testvectors.push_back(cons_test(32'hdd360500, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0034, 64'h0a0b0c0d0a000000)); // ld        (ix+$05),$00
        testvectors.push_back(cons_test(32'hdd360400, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0038, 64'h0a0b0c0d00000000)); // ld        (ix+$04),$00
        testvectors.push_back(cons_test(32'h01040000, 16'h0000, 16'h0004, 16'h0000, 16'h0000, 16'h003b, 64'h0a0b0c0d00000000)); // ld        bc,$0004
        testvectors.push_back(cons_test(32'h11040000, 16'h0000, 16'h0004, 16'h0000, 16'h0000, 16'h003e, 64'h0a0b0c0d00000000)); // ld        de,$0004
        testvectors.push_back(cons_test(32'h21000000, 16'h0000, 16'h0004, 16'h0000, 16'h0000, 16'h0041, 64'h0a0b0c0d00000000)); // ld        hl,$0000
        testvectors.push_back(cons_test(32'hedb00000, 16'h0004, 16'h0003, 16'h0000, 16'h0000, 16'h0041, 64'h0a0b0c0d0a000000)); // ldir
        testvectors.push_back(cons_test(32'hedb00000, 16'h0004, 16'h0002, 16'h0000, 16'h0000, 16'h0041, 64'h0a0b0c0d0a0b0000)); // ldir
        testvectors.push_back(cons_test(32'hedb00000, 16'h0004, 16'h0001, 16'h0000, 16'h0000, 16'h0041, 64'h0a0b0c0d0a0b0c00)); // ldir
        testvectors.push_back(cons_test(32'hedb00000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0043, 64'h0a0b0c0d0a0b0c0d)); // ldir
        testvectors.push_back(cons_reset()); /* the test for cpi */
        //                              instruction   AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back(cons_test(32'h11adde00, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // ld de, dead
        testvectors.push_back(cons_test(32'hed530400, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0008, 64'h00000000adde0000)); // ld ($0004), de
        testvectors.push_back(cons_test(32'h01010000, 16'h0000, 16'h0001, 16'h0000, 16'h0000, 16'h000b, 64'h00000000adde0000)); // ld bc, 1
        testvectors.push_back(cons_test(32'heda10000, 16'h0042, 16'h0000, 16'h0000, 16'h0000, 16'h000d, 64'h00000000adde0000)); // cpi
        testvectors.push_back(cons_test(32'heda10000, 16'h0046, 16'hffff, 16'h0000, 16'h0000, 16'h000f, 64'h00000000adde0000)); // cpi
        testvectors.push_back(cons_test(32'heda10000, 16'h0046, 16'hfffe, 16'h0000, 16'h0000, 16'h0011, 64'h00000000adde0000)); // cpi
        testvectors.push_back(cons_test(32'heda10000, 16'h0046, 16'hfffd, 16'h0000, 16'h0000, 16'h0013, 64'h00000000adde0000)); // cpi
        testvectors.push_back(cons_test(32'heda10000, 16'h0016, 16'hfffc, 16'h0000, 16'h0000, 16'h0015, 64'h00000000adde0000)); // cpi
        testvectors.push_back(cons_reset()); /* the test for cpd */
        //                              instruction   AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back(cons_test(32'h11adde00, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // ld de, dead
        testvectors.push_back(cons_test(32'hed530400, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0008, 64'h00000000adde0000)); // ld ($0004), de
        testvectors.push_back(cons_test(32'h01010000, 16'h0000, 16'h0001, 16'h0000, 16'h0000, 16'h000b, 64'h00000000adde0000)); // ld bc, 1
        testvectors.push_back(cons_test(32'h21070000, 16'h0000, 16'h0001, 16'h0000, 16'h0000, 16'h000e, 64'h00000000adde0000)); // ld hl, 7
        testvectors.push_back(cons_test(32'heda90000, 16'h0042, 16'h0000, 16'h0000, 16'h0000, 16'h0010, 64'h00000000adde0000)); // cpd
        testvectors.push_back(cons_test(32'heda90000, 16'h0046, 16'hffff, 16'h0000, 16'h0000, 16'h0012, 64'h00000000adde0000)); // cpd
        testvectors.push_back(cons_test(32'heda90000, 16'h0016, 16'hfffe, 16'h0000, 16'h0000, 16'h0014, 64'h00000000adde0000)); // cpd
        testvectors.push_back(cons_test(32'h01010000, 16'h0016, 16'h0001, 16'h0000, 16'h0000, 16'h0017, 64'h00000000adde0000)); // ld bc, 1
        testvectors.push_back(cons_test(32'heda90000, 16'h0012, 16'h0000, 16'h0000, 16'h0000, 16'h0019, 64'h00000000adde0000)); // cpd
        testvectors.push_back(cons_reset()); /* the test for cpir */
        //                              instruction   AF        BC        IX        SP        PC        first 8b of memory
        testvectors.push_back(cons_test(32'h11adde00, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0004, 64'h0000000000000000)); // ld de, dead
        testvectors.push_back(cons_test(32'hed530400, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0008, 64'h00000000adde0000)); // ld ($0004), de
        testvectors.push_back(cons_test(32'h01040000, 16'h0000, 16'h0004, 16'h0000, 16'h0000, 16'h000b, 64'h00000000adde0000)); // ld bc, 1
        testvectors.push_back(cons_test(32'h3ede0000, 16'hde00, 16'h0004, 16'h0000, 16'h0000, 16'h000d, 64'h00000000adde0000)); // ld a, de
        testvectors.push_back(cons_test(32'hedb10000, 16'hde16, 16'h0004, 16'h0000, 16'h0000, 16'h000d, 64'h00000000adde0000)); // ld a, de

        ->test_start;


        $display("idx  | instruction |   AF |   BC |   IX |   SP |   PC | memory    ");

        foreach (testvectors[i]) begin
            automatic test_vector current_test = testvectors[i];

            /* application of the test vector in the fetch region */
            @frame_start;
            instruction = current_test.instruction;
            test_idx = i;
            if (current_test.reset == 1) begin
                reset_tb();
            end;


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
                current_test.AF,
                current_test.BC,
                current_test.IX,
                current_test.SP,
                current_test.PC,
                current_test.test_ram
            );

            if (
                current_test.AF == {main_reg_set[0], main_reg_set[1]} &&
                current_test.BC == {main_reg_set[2], main_reg_set[3]} &&
                current_test.IX == special_reg_set[1] &&
                current_test.SP == special_reg_set[3] &&
                current_test.PC == special_reg_set[4] &&
                current_test.test_ram == {
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
