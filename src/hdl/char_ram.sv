`timescale 1ns/1ps

//! Character RAM stores ASCII value for each screen cell
//! 80 x 60 characters

<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
>>>>>>> Stashed changes
);

<<<<<<< Updated upstream
assign char_ram_data = RW[char_ram_address[12:0]];

always_ff @(posedge clk) begin
    if ( w_en ) begin
        RW[address[12:0]] <= data_in;
    end
end
always_comb begin
    if (r_en)
        data_out = RW[address[12:0]];
    else
        data_out = 8'hZZ;
end
=======
    localparam TOTAL_CHARS = 80 * 60;
>>>>>>> Stashed changes
=======
);

    localparam TOTAL_CHARS = 80 * 60;
>>>>>>> Stashed changes

    // Memory array
    logic [7:0] mem [0:TOTAL_CHARS-1];

    // Write logic (AXI clock domain)
    always_ff @(posedge axi_clk) begin
        if (w_en) begin
            mem[write_address] <= data_in;
        end
    end

    // Read logic (pixel/VGA clock domain)
    always_ff @(posedge pixel_clk) begin
        data_out <= mem[read_address];
    end

endmodule