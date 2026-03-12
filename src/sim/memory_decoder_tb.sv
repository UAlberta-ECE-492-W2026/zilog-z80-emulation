`timescale 1ns/1ps

module memory_decoder_tb();

logic [15:0] address;
logic WR;
logic RD;
logic MREQ;

logic WE_RAM;
logic RD_RAM;
logic RD_ROM;
logic CS_ROM;
logic CS_RAM;

memory_decoder dut (
    .address(address),
    .WR(WR),
    .RD(RD),
    .MREQ(MREQ),
    .WE_RAM(WE_RAM),
    .RD_RAM(RD_RAM),
    .RD_ROM(RD_ROM),
    .CS_ROM(CS_ROM),
    .CS_RAM(CS_RAM)
);

initial begin
    $monitor("inputs: time=%0t addr=%h RD=%b WR=%b MREQ=%b | outputs: CS_ROM=%b CS_RAM=%b WE_RAM=%b RD_ROM=%b RD_RAM=%b",
                $time, address, RD, WR, MREQ, CS_ROM, CS_RAM, WE_RAM, RD_ROM, RD_RAM);
end

initial begin

    // ROM read
    address = 16'h0000;
    RD = 1;
    WR = 0;
    MREQ = 1;
    #10;

    // RAM read
    address = 16'h0700;
    RD = 1;
    WR = 0;
    #10;

    // RAM write
    address = 16'h0700;
    RD = 0;
    WR = 1;
    #10;

    $finish;
end

endmodule
