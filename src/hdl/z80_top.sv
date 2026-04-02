// Decided to make this a different module to reduce the amount of macros needed in the 'real' z80_top module

`timescale 1ns/1ps

`define USE_AXI_KEYBOARD

module z80_top #(
    /*
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
    */
)(
    // display driving outputs
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue,        //! blue channel (4-bit)

    // debug inputs and outputs.
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[3:0] buttons,
    input logic [3:0] switches,
    output logic[3:0] LEDs,
    /* verilator lint_on UNUSEDSIGNAL */

    // clock
    input logic clk

    // AXI interface
    /*
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready
    */
);    
    logic[15:0] char_ram_address;
    logic[7:0] char_ram_data;

    assign LEDs = 4'b1111;

    c_to_dp_intf intf();
    // debug clock
    assign intf.clk = switches[0] ? switches[1] : clk;
    assign intf.reset =  buttons[0];

    controller #() controller (intf);
    controller_next_state next_state_logic(.ctrl_intf(intf));
    controller_output output_logic(.intf(intf));
    datapath #() datapath (
        .intf(intf)
    );

    memory_wrapper #() memory_wrapper(
        .intf(intf), 
        .char_ram_address(char_ram_address), 
        .char_ram_data(char_ram_data)
    );

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
