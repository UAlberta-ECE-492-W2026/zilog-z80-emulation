`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! 80 columns x 60 rows = 4800 cells

module char_ram
(
output reg [7:0] data_out,
input wire [12:0] address,
input wire WE,
input wire [7:0] data_in
);

reg[7:0] RW[0:4799];

always_comb begin
    if (WE) begin
        RW[address] <= data_in;
    end
    data_out = RW[address];
end

endmodule