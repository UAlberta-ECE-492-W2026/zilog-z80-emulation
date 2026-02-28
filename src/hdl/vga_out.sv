`timescale 1ns/1ps

//! VGA text driver
//! This module generates full VGA timing and renders text
//! using an internal character RAM and font ROM.
//! Each character cell is 8x8 pixels.
//! Total grid is 80 columns x 60 rows.
//! 640x480 @ 60Hz
//! 8x8 font

module vga_out
(
    input  logic clk,              //! 25 MHz pixel clock required for 640x480 @60Hz
    input  logic reset,            //! synchronous reset for counters
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue        //! blue channel (4-bit)
);

    //! VGA timing parameters

    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    //! Signals from external counter modules

    logic enable_vertical_counter;           
    logic [15:0] horizontal_count_value;     
    logic [15:0] vertical_count_value;       

    horizontal_counter VGA_horizontal (
        .clk(clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .horizontal_count_value(horizontal_count_value)
    );

    vertical_counter VGA_vertical (
        .clk(clk),
        .reset(reset),
        .enable_vertical_counter(enable_vertical_counter),
        .vertical_count_value(vertical_count_value)
    );

    //! Sync pulses are active LOW

    assign hsync = ~((horizontal_count_value >= (H_VISIBLE + H_FRONT)) &&
                     (horizontal_count_value <  (H_VISIBLE + H_FRONT + H_SYNC)));

    assign vsync = ~((vertical_count_value >= (V_VISIBLE + V_FRONT)) &&
                     (vertical_count_value <  (V_VISIBLE + V_FRONT + V_SYNC)));

    //! Visible region is 640x480

    logic visible;

    assign visible = (horizontal_count_value < H_VISIBLE) &&
                     (vertical_count_value   < V_VISIBLE);

    //! Character RAM stores ASCII value for each screen cell
    //! 80 columns x 60 rows = 4800 cells

    logic [7:0] char_ram [0:4799];

    integer i;

    initial begin
        //! Draws A to the screen in every cell
        for (i = 0; i < 4800; i = i + 1)
            char_ram[i] = 8'd65;
    end

    //! Font ROM stored as a bitmap with each ASCII character
    //! 256 characters, 8 rows each, 8 bits per row

    logic [7:0] font_rom [0:2047];

    integer c;

    initial begin
        //! Clear all font patterns
        for (c = 0; c < 2048; c = c + 1)
            font_rom[c] = 8'b00000000;

        //! Letter 'A' (ASCII 65)
        font_rom[65*8 + 0] = 8'b00011000;
        font_rom[65*8 + 1] = 8'b00100100;
        font_rom[65*8 + 2] = 8'b01000010;
        font_rom[65*8 + 3] = 8'b01111110;
        font_rom[65*8 + 4] = 8'b01000010;
        font_rom[65*8 + 5] = 8'b01000010;
        font_rom[65*8 + 6] = 8'b01000010;
        font_rom[65*8 + 7] = 8'b00000000;
    end

    //! Current pixel coordinates from external counters

    logic [9:0] x;
    logic [9:0] y;

    assign x = horizontal_count_value[9:0];
    assign y = vertical_count_value[9:0];

    //! Dividing by 8 to determine character cell position

    logic [6:0] col;   
    logic [5:0] row;   

    assign col = x >> 3;
    assign row = y >> 3;

    //! the lower 3 bits gives the specific pixel inside current cell

    logic [2:0] px;
    logic [2:0] py;

    assign px = x[2:0];
    assign py = y[2:0];

    //! Character memory address (row * 80 + col)
    //! Implemented as row*64 + row*16 to avoid hardware multiplier
    //! Logic shifts can be done without multiplying

    logic [12:0] char_address;
    logic [7:0]  ascii;

    assign char_address = (row << 6) + (row << 4) + col;  //! row*80 + col

    assign ascii = visible ? char_ram[char_address] : 8'd0; //! read character only in visible area

    logic [7:0] font_row;   //! row of ascii character to be printed
    logic pixel_on;         //! pixel enable signal

    assign font_row = font_rom[ascii*8 + py]; //! select row inside ascii character

    assign pixel_on = font_row[7 - px]; //! select horizontal pixel inside ascii character pixel representation

    //! Drive RGB colour outputs

    always_comb begin
        if (visible && pixel_on) begin
            red   = 4'hF;
            green = 4'hF;
            blue  = 4'hF;
        end
        else begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end
    end

endmodule
