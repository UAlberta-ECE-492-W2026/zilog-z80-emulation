`timescale 1ns/1ps

module z80_top #(
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
    input logic clk

    // AXI interface missing
);
    logic[15:0] char_ram_address;
    logic[7:0] char_ram_data;
    logic reset;
    assign reset = buttons[0];

    assign LEDs = 4'b1111;

    c_to_dp_intf intf();
    controller #() controller (intf);
    controller_next_state next_state_logic(.ctrl_intf(intf));
    controller_output output_logic(.intf(intf));
    datapath #() datapath (intf);
    memory_wrapper #() memory_wrapper(.intf(intf), .char_ram_address(char_ram_address), .char_ram_data(char_ram_data));
    vga_out #() vga_out(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .char_ram_address(char_ram_address),
        .char_ram_data(char_ram_data)
    );

endmodule
