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
    input  logic clk,              //! 125 MHz pixel clock from Zybo z-7
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

    // Clock divider to drive the external counters to the module
    logic [2:0] div_count;
    logic pixel_clk;
    //assign pixel_clk = clk;

    always_ff @(posedge clk) begin
        if (reset) begin
            div_count <= 0;
            pixel_clk <= 0;
        end
        else begin
            if (div_count == 0) begin
                div_count <= 0;
                pixel_clk <= ~pixel_clk;
            end else begin
                div_count <= div_count + 1;
            end
        end
    end


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
    
    //localparam CHAR_ROWS = V_VISIBLE / 8;
    //localparam CHAR_COLL = H_VISIBLE / 8;

    //! Signals from external modules
    logic enable_vertical_counter;           
    logic [15:0] horizontal_count_value;     
    logic [15:0] vertical_count_value;    
    reg [7:0] data_out_rom;
    logic [10:0] address_rom;
    
    horizontal_counter #(H_TOTAL) VGA_horizontal (
        .clk(pixel_clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .horizontal_count_value(horizontal_count_value)
    );

    vertical_counter #(V_TOTAL) VGA_vertical (
        .clk(pixel_clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .vertical_count_value(vertical_count_value)
    );

    font_rom font_rom (
        .clk(pixel_clk),
        .data_out(data_out_rom),
        .address(address_rom)
    );
    
    //! Sync pulses are active LOW
    assign hsync = ~((horizontal_count_value >= (H_VISIBLE + H_FRONT)) &&
                     (horizontal_count_value <  (H_VISIBLE + H_FRONT + H_SYNC)));

    assign vsync = ~((vertical_count_value >= (V_VISIBLE + V_FRONT)) &&
                     (vertical_count_value <  (V_VISIBLE + V_FRONT + V_SYNC)));

    //! Current pixel coordinates from external counters
    logic [15:0] x;
    logic [15:0] y;
    assign x = horizontal_count_value[15:0];
    assign y = vertical_count_value[15:0];

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
        end else if (horizontal_count_value < H_VISIBLE && vertical_count_value < V_VISIBLE) begin
            background = 1;
        end
    end

    logic [2:0] px_1_clk_delay;
    logic visible_1_clk_delay;
    logic [7:0] font_row;  //!row of ascii character to be printed
    logic pixel_on;  //!pixel enable signal
    logic [10:0] font_address;
    always_ff @( posedge pixel_clk ) begin
        px_1_clk_delay <= px;
        visible_1_clk_delay <= visible;
    end

    //! the lower 3 bits gives the specific pixel inside current cell
    logic [2:0] px;
    logic [2:0] py;
    assign px = x[2:0];
    assign py = y[2:0];

    assign font_address = ({3'b0, ascii} << 3) + {8'b0, py};
    assign address_rom = font_address;  //! send address to font ROM
    assign font_row = data_out_rom[7:0];  //! bitmap row returned from ROM

    assign pixel_on = font_row[7 - px_1_clk_delay];  //! select horizontal pixel inside font

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
