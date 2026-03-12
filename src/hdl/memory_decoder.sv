`timescale 1ns/1ps
// Memory map decoder
// This module selects between the ROM and the RAM(s)
module memory_decoder
(
    input logic [15:0] address,  // Address bus for memory Read/Write
    input logic WR,  // Write enable control for memory
    input logic RD,  // Read enable control for memory
    input logic MREQ,  // Memory request from Z80

    output logic WE_RAM,  // Write enable for the RAM
    output logic RD_RAM,  // Read enable for the RAM
    output logic RD_ROM,  // Read enable for the ROM
    output logic CS_ROM,  // Chip select for ROM
    output logic CS_RAM   // Chip select for RAM
);

always_comb begin

    WE_RAM = 0;
    RD_RAM = 0;
    RD_ROM = 0;
    CS_ROM = 0;
    CS_RAM = 0;

    if (MREQ) begin

        if(address <= 16'h06FF) begin  // Memory location for font ROM
            CS_ROM = 1;
            if (RD) begin
                RD_ROM = 1;
            end
        end

        else if(address >= 16'h0700 && 16'h0CFF >= address) begin  // Memory location for char RAM
            CS_RAM = 1;
            if (RD) begin
                RD_RAM = 1;
            end
            if (WR) begin
                WE_RAM = 1;
            end
        end

        else if(address >= 16'h0D00) begin  // Memory location for Keyboard IO RAM
            CS_RAM = 1;
            if (RD) begin
                RD_RAM = 1;
            end
            if (WR) begin
                WE_RAM = 1;
            end
        end

    end

end

endmodule
