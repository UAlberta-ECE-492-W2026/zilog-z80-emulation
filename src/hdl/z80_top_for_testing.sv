// Decided to make this a different module to reduce the amount of macros needed in the 'real' z80_top module

`timescale 1ns/1ps
`include "mop.sv"

`define USING_VERILATOR
`ifndef SV_TESTBENCH
`define SOFTWARE_KEYBOARD
`endif
module z80_top_for_testing #(
)(
    // display driving outputs
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue,        //! blue channel (4-bit)

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
    `ifdef Z80_MEMORY_DEBUG
    input logic [31:0] instruction,
    input logic override_instruction,
    output logic [7:0] test_ram [0:7],
    `endif
    output uop::uop_t state,
    output mop mop_out

    `ifdef SOFTWARE_KEYBOARD
    ,
    input logic [7:0] keyboard_char_input,
    output logic [7:0] keyboard_char_output,
    output logic read_char,
    output logic write_char

    `endif
);    
    logic[15:0] char_ram_address;
    logic[7:0] char_ram_data;

    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] memory_mapped_display_byte;
    /* verilator lint_on UNUSEDSIGNAL */

    assign LEDs = 4'b1111;

    c_to_dp_intf intf();
    assign intf.clk = clk;
    assign intf.reset =  buttons[0];

    assign state = intf.current_state;
    assign mop_out = intf.mop_out;

    controller #() controller (intf);
    controller_next_state next_state_logic(.ctrl_intf(intf));
    controller_output output_logic(.intf(intf));
    datapath #() datapath (
        .intf(intf), 
        .debug_main_reg_set(main_reg_set), 
        .debug_special_reg_set(special_reg_set)
    );

    memory_wrapper #() memory_wrapper(
        .intf(intf), 
        .char_ram_address(char_ram_address), 
        .char_ram_data(char_ram_data),
        `ifdef Z80_MEMORY_DEBUG
        .override_instruction(override_instruction), 
        .override_instruction_data(instruction), 
        .test_ram(test_ram),
        `endif
        .memory_mapped_display_byte(memory_mapped_display_byte)
        `ifdef SOFTWARE_KEYBOARD
        ,
        .software_keyboard_char_input(keyboard_char_input),
        .software_keyboard_char_output(keyboard_char_output),
        .software_keyboard_read_char(read_char),
        .software_keyboard_write_char(write_char)
        `endif
    );

    vga_out #() vga_out(
        .pixel_clk(clk),
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
