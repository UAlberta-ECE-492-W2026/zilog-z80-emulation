`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! CHAR_COLL columns x CHAR_ROWS rows

module char_ram #()(
    input  logic clk,
    output logic [7:0] data_out,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [15:0] address,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic WE,
    input  logic [7:0] data_in
);
localparam total_chars = 80*60;
logic [7:0] RW[0:total_chars - 1];

always_ff @(posedge clk) begin
    if (WE)
        RW[address[12:0]] <= data_in;

    data_out <= RW[address[12:0]];
end

endmodule
