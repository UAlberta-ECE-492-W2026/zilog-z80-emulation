`timescale 1ns/1ps

//! Horizontal counter module for VGA driver.
//! This driver module integrates the 640x480 VGA (VESA) resolution.
//! According to this resolution standard 640 pixels horizontal displaying
//! requires 800 pixels total per line.
//! The increase of 160 pixels is due to the front and back porch (and etc) of the VGA signal.

module horizontal_counter
(
input logic clk, //! might need to change with clk divider depending on refresh rate desired
output reg [15:0] horizontal_count_value = 0,
output reg enable_vertical_counter = 0
);

always@(posedge clk) begin
    if (horizontal_count_value < 799) begin
        horizontal_count_value <= horizontal_count_value + 1; //! increment horizontal counter to next pixel
        enable_vertical_counter <= 0; //! stay on current vertical line
    end
    else begin
        horizontal_count_value <= 0; //! reset horizontal counter
        enable_vertical_counter <= 1; //! trigger vertical counter causing next veritical line to draw
    end
end

endmodule