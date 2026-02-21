`timescale 1ns/1ps

//! VGA out module for the VGA driver.
//! This module will currently output an all white display.
//! The constraint files must be set up correctly to drive
//! the PMOD to VGA adapter correctly.
//! NOTE: clk might require a clk divider.
//! The PMOD to VGA adapter allows for a 150 MHz pixel clock max.

module vga_out
(
input logic clk,
output logic horizontal_sync,
output logic vertical_sync,
output logic [3:0] red,
output logic [3:0] green,
output logic [3:0] blue
);

logic enable_vertical_counter;
logic [15:0] horizontal_count_value;
logic [15:0] vertical_count_value;

horizontal_counter VGA_horizontal (
    .clk(clk),
    .enable_vertical_counter(enable_vertical_counter),
    .horizontal_count_value(horizontal_count_value)
);

vertical_counter VGA_vertical (
    .clk(clk),
    .enable_vertical_counter(enable_vertical_counter),
    .vertical_count_value(vertical_count_value)
);

//! Outputs for vertical and horizontal sync signals
assign horizontal_sync = (horizontal_count_value < 96) ? 1'b1:1'b0;
assign vertical_sync = (vertical_count_value < 2) ? 1'b1:1'b0;

//! Output colours to display
//! currently set to display every colour to every colour at everu pixel
//! this will create a white screen
//! NOTE: update later to correct pixel location of each ASCII value.
//! ASCII driver and memory mapping to be done in C.
//! This will allow the display of text from the Adventure Game in the correct location
assign red = (horizontal_count_value < 784 && horizontal_count_value > 143 && vertical_count_value < 515 && vertical_count_value > 34) ? 4'hF:4'h0;
assign green = (horizontal_count_value < 784 && horizontal_count_value > 143 && vertical_count_value < 515 && vertical_count_value > 34) ? 4'hF:4'h0;
assign blue = (horizontal_count_value < 784 && horizontal_count_value > 143 && vertical_count_value < 515 && vertical_count_value > 34) ? 4'hF:4'h0;

endmodule
