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
localparam total_chars = 80 * 60;
logic [7:0] RW[0:total_chars - 1];


always_ff @(posedge clk) begin
    char_ram_data <= RW[char_ram_address[12:0]];
    if ( w_en ) begin
        RW[address[12:0]] <= data_in;
    end
    if (r_en) begin
        data_out <= RW[address[12:0]];
    end
end

endmodule
