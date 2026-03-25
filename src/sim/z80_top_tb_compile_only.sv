`timescale 1ns/1ps
// empty tb just to test if verilator compiles everything

module z80_top_tb_compile_only #() ();
    // display driving outputs
    /* verilator lint_off UNUSEDSIGNAL */
    logic hsync;            //! horizontal sync (active LOW)
    logic vsync;            //! vertical sync (active LOW)
    logic [3:0] red;        //! red channel (4-bit)
    logic [3:0] green;      //! green channel (4-bit)
    logic [3:0] blue;        //! blue channel (4-bit)

    // debug inputs and outputs. TODO: attach these to something
    logic[3:0] buttons;
    logic[3:0] LEDs;

    // clock
    logic clk;
    /* verilator lint_on UNUSEDSIGNAL */

    assign buttons = 4'b0000;
    assign clk = 0;

    z80_top #() z80_top (
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .buttons(buttons),
        .LEDs(LEDs),
        .clk(clk)
    );

endmodule
