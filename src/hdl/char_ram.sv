`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! CHAR_COLL columns x CHAR_ROWS rows

module char_ram #()(
    input  logic clk,
    output logic [7:0] data_out,
    
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [15:0] address,
    /* verilator lint_on UNUSEDSIGNAL */

    // second port for vga wrapper to talk to on a seperate clock domain
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [15:0] char_ram_address,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [7:0] char_ram_data,

    input  logic w_en,
    input  logic r_en,
    input  logic [7:0] data_in
);
localparam total_chars = 80*60;
logic [7:0] RW[0:total_chars - 1];

assign char_ram_data = RW[char_ram_address[12:0]];

always_ff @(posedge clk) begin
    if (w_en)
        RW[address[12:0]] <= data_in;
end
always_comb begin
    if (r_en)
        data_out = RW[address[12:0]];
    else
        data_out = 8'hZZ;
end

endmodule
