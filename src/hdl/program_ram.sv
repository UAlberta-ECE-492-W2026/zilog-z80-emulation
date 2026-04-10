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
    input logic [15:0]  address,
    input logic [7:0]   data_in,
    output logic [7:0]  data_out_8,
    output logic [31:0] data_out_32
);
    //logic [7:0] mem[0:60159]; // total space is 2^ 16 - (2^8) - (2^12 + 2 ^10)
    logic [7:0] mem[0:60416]/*verilator public*/; // total space is 2^ 16 - (2^12 + 2 ^10)

    initial begin
        //$readmemb("F:\\School\\School_U\\t9\\ECE_492\\zilog-z80-emulation\\zilog-z80-emulation-software\\internal_programs\\blinker\\blinker.vivado", mem, 0, 60416);
        //$readmemb("F:\\School\\School_U\\t9\\ECE_492\\zilog-z80-emulation\\zilog-z80-emulation-software\\internal_programs\\echo\\echo.vivado", mem, 0, 60416);
        $readmemb("F:\\School\\School_U\\t9\\ECE_492\\zilog-z80-emulation\\zilog-z80-emulation-software\\external_programs\\Advent\\Almazar\\almazar.vivado", mem, 0, 60416);
        //$readmemb("F:\\School\\School_U\\t9\\ECE_492\\zilog-z80-emulation\\zilog-z80-emulation-software\\tests\\z80test\\src\\z80doc.vivado", mem, 0, 60416);
        //$readmemb("zilog-z80-emulation-software/internal_programs/blinker/blinker.vivado", mem, 0, 60159);
        //$readmemb("zilog-z80-emulation-software/internal_programs/prime_printer/prime_printer.vivado", mem, 0, 60416);
        //$readmemb("zilog-z80-emulation-software/tests/z80test/src/z80doc.vivado", mem, 0, 60416);
        //$readmemb("zilog-z80-emulation-software/external_programs/Advent/Almazar/almazar.vivado", mem, 0, 60159);

    end

    always_ff @(posedge clk) begin
        if (w_en) begin
            mem[address] <= data_in;
        end
        data_out_8 <= mem[address];
        data_out_32 <= {mem[address], mem[address+1], mem[address+2],mem[address+3]};
    end


endmodule
`endif
