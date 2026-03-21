`timescale 1ns/1ps

// the main RAM of the system

module char_ram #()(
    input logic         clk,
    input logic         reset,
    input logic         w_en,
    input logic         r_en,
    input logic [15:0]  address,
    input logic [7:0]   data_in,
    output logic [7:0]  data_out_8,
    output logic [31:0] data_out_32
);
    logic [7:0] mem[256:60415]; // total space is 2^ 16 - (2^8) - (2^12 + 2 ^10)

    always_ff @(posedge clk) begin
        if (reset == 1) begin
            mem <= '{default:8'h00};
        end else begin
            if (w_en) begin
                mem[address] <= data_in;
            end
            if (r_en) begin
                data_out_8 <= mem[address];
                data_out_32 <= {mem[address + 3], mem[address + 2], mem[address + 1],mem[address + 0]}; // this might be backwards
            end
        end
    end
endmodule
