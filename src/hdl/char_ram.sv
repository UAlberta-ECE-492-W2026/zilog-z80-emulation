`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! 80 columns x 60 rows = 4800 cells

module char_ram
(
    input  logic clk,
    output logic [7:0] data_out,
    input  logic [12:0] address,
    input  logic WE,
    input  logic [7:0] data_in
);

logic [7:0] RW[0:4799];

always_ff @(posedge clk) begin
    if (WE)
        RW[address] <= data_in;

    data_out <= RW[address];
end

endmodule