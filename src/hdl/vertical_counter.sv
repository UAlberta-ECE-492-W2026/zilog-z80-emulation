`timescale 1ns/1ps

//! Vertical counter module for VGA driver.
//! This driver module integrates the 640x480 VGA (VESA) resolution.
//! According to this resolution standard 480 pixels horizontal displaying
//! requires 525 pixels total per line.
//! The increase of 45 pixels is due to the front and back porch (and etc) of the VGA signal.

module vertical_counter
(
input logic clk, //! might need to change with clk divider depending on refresh rate desired
output reg [15:0] vertical_count_value = 0,
output reg enable_vertical_counter = 0
);

always@(posedge clk) begin
    if (enable_vertical_counter == 1'b1) begin
        if (vertical_count_value < 524) begin
            vertical_count_value <= vertical_count_value + 1; //! incremental vertical count value to next pixel
        end
        else begin
            vertical_count_value <= 0; //! reset vertical count value
        end
    end
end

endmodule