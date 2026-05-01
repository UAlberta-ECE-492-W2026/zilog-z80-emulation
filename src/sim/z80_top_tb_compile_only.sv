`timescale 1ns/1ps

// linting doesn't catch everything, so this was made to just try verilating the whole design so we can see what's broken.
module z80_top_tb_compile_only #() ();
    /* verilator lint_off UNUSEDSIGNAL */
    logic hsync;            //! horizontal sync (active LOW)
    logic vsync;            //! vertical sync (active LOW)
    logic [3:0] red;        //! red channel (4-bit)
    logic [3:0] green;      //! green channel (4-bit)
    logic [3:0] blue;        //! blue channel (4-bit)

    logic[3:0] buttons = 0;
    logic[3:0] switches = 0;
    logic[3:0] LEDs;
    logic [3:0] je;
    logic [3:0] ja;
    logic led6_r, led6_g, led6_b;
    logic clk;
    assign clk = 0;
    /* verilator lint_on UNUSEDSIGNAL */

    z80_top #() z80_top (
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .buttons(buttons),
        .switches(switches),
        .je(je),
        .ja(ja),
        .LEDs(LEDs),
        .led6_g(led6_g),
        .led6_r(led6_r),
        .led6_b(led6_b),
        .clk(clk)
    );

endmodule
