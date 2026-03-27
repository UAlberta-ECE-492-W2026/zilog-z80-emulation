// Decided to make this a different module to reduce the amount of macros needed in the 'real' z80_top module

`timescale 1ns/1ps

`define Z80_TOP_TESTING
module z80_top_for_testing #(
)(
    // display driving outputs
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue,        //! blue channel (4-bit)
    output uop::uop_t state,

    // debug inputs and outputs. TODO: attach these to something
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[3:0] buttons,
    output logic[3:0] LEDs,
    /* verilator lint_on UNUSEDSIGNAL */

    // clock
    input logic clk,

    // AXI interface missing

    // debug
    output logic [7:0] main_reg_set [0:7],
    output logic [15:0] special_reg_set [0:4],
    input logic [31:0] instruction,
    output logic [7:0] test_ram [0:7]
);
    import uop::*;
    
    logic[15:0] char_ram_address;
    logic[7:0] char_ram_data;

    assign LEDs = 4'b1111;

    c_to_dp_intf intf();
    assign intf.clk = clk;
    assign intf.reset =  buttons[0];

    assign state = intf.current_state;

    controller #() controller (intf);
    controller_next_state next_state_logic(.ctrl_intf(intf));
    controller_output output_logic(.intf(intf));
    datapath #() datapath (.intf(intf), .debug_main_reg_set(main_reg_set), .debug_special_reg_set(special_reg_set));
    memory_wrapper #() memory_wrapper(.intf(intf), .char_ram_address(char_ram_address), .char_ram_data(char_ram_data), .override_instruciton(1'b1), .override_instruciton_data(instruction), .test_ram(test_ram));
    vga_out #() vga_out(
        .clk(clk),
        .reset(buttons[0]),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .char_ram_address(char_ram_address),
        .char_ram_data(char_ram_data)
    );

endmodule
