//`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! CHAR_COLL columns x CHAR_ROWS rows

module char_ram(
    input  logic clk,
    output logic [7:0] data_out,
    input  logic [15:0] address,
    input  logic w_en,
    input  logic [7:0] data_in
);

localparam total_chars = 80 * 60;
logic [7:0] RW[0:total_chars - 1];

always_ff @(posedge clk) begin
    if (w_en)
        RW[address] <= data_in;

    data_out <= RW[address];
end

endmodule
