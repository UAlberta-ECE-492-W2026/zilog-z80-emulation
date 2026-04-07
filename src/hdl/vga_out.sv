`timescale 1ns/1ps

//! VGA text driver
//! This module generates full VGA timing and renders text
//! using the character RAM and font ROM.
//! Each character cell is 8x8 pixels.
//! Total grid is 80 columns x 60 rows.
//! 640x480 @ 60Hz
//! 8x8 font

module vga_out
(
    input  logic pixel_clk,        //! pixel clock from top. Correct frequency depends on the number of pixels per frame. Ideally pixel_clk frequency / (H_TOTAL * V_TOTAL) = ~60Hz
    input  logic reset,            //! synchronous reset for counters
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue,        //! blue channel (4-bit)

    // char ram connections
    output logic [15:0] char_ram_address,
    input logic [7:0] char_ram_data
);


    // TODO: make these not local
    //! VGA timing parameters
    /* verilator lint_off UNUSEDPARAM */
    localparam H_VISIBLE = 1024;
    localparam H_FRONT   = 24;
    localparam H_SYNC    = 136;
    localparam H_BACK    = 160;
    localparam H_TOTAL   = 1344;

    localparam V_VISIBLE = 768;
    localparam V_FRONT   = 3;
    localparam V_SYNC    = 6;
    localparam V_BACK    = 29;
    localparam V_TOTAL   = 806;
    /* verilator lint_on UNUSEDPARAM */
    
    //! Signals from external modules
    logic enable_vertical_counter;           
    logic [15:0] x;     
    logic [15:0] y;    
    reg [7:0] data_out_rom;
    logic [10:0] address_rom;
    
    horizontal_counter #(H_TOTAL) VGA_horizontal (
        .clk(pixel_clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .horizontal_count_value(x)
    );

    vertical_counter #(V_TOTAL) VGA_vertical (
        .clk(pixel_clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .vertical_count_value(y)
    );

    font_rom font_rom (
        .clk(pixel_clk),
        .data_out(data_out_rom),
        .address(address_rom)
    );
    
    //! Sync pulses are active LOW
    assign hsync = ~((x >= (H_VISIBLE + H_FRONT)) &&
                     (x <  (H_VISIBLE + H_FRONT + H_SYNC)));

    assign vsync = ~((y >= (V_VISIBLE + V_FRONT)) &&
                     (y <  (V_VISIBLE + V_FRONT + V_SYNC)));


    //! Dividing by 8 to determine character cell position
    logic [15:0] col;   
    logic [15:0] row;   
    assign col = x >> 3;
    assign row = y >> 3;

    logic [7:0]  ascii;
    logic visible;
    logic background;

    always_comb begin
        ascii = 0;
        char_ram_address = 0;
        visible = 0;
        background = 0;
        if ((row < 60) && (col < 80)) begin
            char_ram_address = row * 80 + col;
            ascii = char_ram_data;  // returned from char RAM
            visible = 1;
        end else if (x < H_VISIBLE && y < V_VISIBLE) begin
            background = 1;
        end
    end

    logic [2:0] px_1_clk_delay;
    logic visible_1_clk_delay;
    logic [7:0] font_row;  //!row of ascii character to be printed
    logic pixel_on;  //!pixel enable signal
    logic [10:0] font_address;
    always_ff @( posedge pixel_clk ) begin
        px_1_clk_delay <= x[2:0];
        visible_1_clk_delay <= visible;
    end

    assign address_rom = ({3'b0, ascii} << 3) + {8'b0, y[2:0]};
    assign pixel_on = data_out_rom[7 - px_1_clk_delay];  //! select horizontal pixel inside font

    //! Drive RGB colour outputs
    always_comb begin
        if (visible_1_clk_delay && pixel_on) begin
            red   = 4'hF;
            green = 4'hF;
            blue  = 4'hF;
        end else if (background) begin
            red   = 4'h4;
            green = 4'h4;
            blue  = 4'h4;
        end else begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end
    end
    
endmodule
