`timescale 1ns/1ps

// the main RAM of the system
`ifndef PROGRAM_RAM
`define PROGRAM_RAM
module program_ram #()(
    input logic         clk,
    /* verilator lint_off UNUSEDSIGNAL */
    input logic         reset,
    /* verilator lint_on UNUSEDSIGNAL */
    input logic         w_en,
    input logic         r_en,
    input logic [15:0]  address,
    input logic [7:0]   data_in,
    output logic [7:0]  data_out_8,
    output logic [31:0] data_out_32
);
    logic [7:0] mem[0:60159]; // total space is 2^ 16 - (2^8) - (2^12 + 2 ^10)
    wire [15:0] local_address;
    assign local_address = address - 256;

    initial begin
        // this should work with vivado as well as verilator
        $readmemb("F:\\School\\School U\\t9\\ECE_492\\zilog-z80-emulation\\zilog-z80-emulation-software\\internal_programs\\blinker\\blinker.vivado", mem, 0, 60159);
    end

    always_ff @(posedge clk) begin
        if (w_en) begin
            mem[local_address] <= data_in;
        end
        if (r_en) begin
            data_out_8 <= mem[local_address];
            data_out_32 <= {mem[local_address], mem[local_address+1], mem[local_address+2],mem[local_address+3]};
        end
    end


endmodule
`endif
