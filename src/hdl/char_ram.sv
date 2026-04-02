`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! 80 x 60 characters

module char_ram (
    // Write port (AXI clock domain)
    input  logic        axi_clk,
    input  logic        w_en,
    input  logic [12:0] write_address,
    input  logic [7:0]  data_in,
    // Read port (pixel clock domain)
    input  logic        pixel_clk,
    input  logic [12:0] read_address,
    output logic [7:0]  data_out
);

    localparam TOTAL_CHARS = 80 * 60;
    logic [7:0] mem [0:TOTAL_CHARS-1];

    always_ff @(posedge axi_clk) begin
        if ( w_en ) begin
            mem[write_address] <= data_in;
        end
    end

    always_ff @(posedge pixel_clk) begin
        data_out <= mem[read_address];
    end

endmodule