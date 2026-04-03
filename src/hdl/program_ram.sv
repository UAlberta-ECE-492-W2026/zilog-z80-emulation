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

    initial begin
        // this should work with vivado as well as verilator
        $readmemb("zilog-z80-emulation-software/internal_programs/hello_world/hello_world.vivado", mem, 0, 60159);
    end

    always_ff @(posedge clk) begin
        if (w_en) begin
            mem[address - 256] <= data_in;
        end
        if (r_en) begin
            data_out_8 <= mem[address - 256];
            data_out_32 <= {mem[address - 256], mem[address - 255], mem[address - 254],mem[address - 253]};
        end else begin
            data_out_8 <= 0;
            data_out_32 <= 0;
        end
    end


endmodule
`endif
