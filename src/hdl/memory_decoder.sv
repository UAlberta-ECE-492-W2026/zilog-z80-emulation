`timescale 1ns/1ps
// Memory map decoder
// This module selects between the ROM and the RAM(s)
// see the Memory Map tab of the Instruction Table sheet
module memory_decoder
(
    input logic [15:0] address,
    input logic w_en,
    input logic r_en,

    output logic w_en_config_ROM,
    output logic r_en_config_ROM,
    output logic [15:0] address_config_ROM,

    output logic w_en_program_RAM,
    output logic r_en_program_RAM,
    output logic [15:0] address_program_RAM,

    output logic w_en_char_RAM,
    output logic r_en_char_RAM,
    output logic [15:0] address_char_RAM,

    output logic w_en_keyboard_IO,
    output logic r_en_keyboard_IO,
    output logic [15:0] address_keyboard_IO
);
    always_comb begin
        w_en_config_ROM = 0;
        r_en_config_ROM = 0;
        address_config_ROM = 0;
        w_en_program_RAM = 0;
        r_en_program_RAM = 0;
        address_program_RAM = 0;
        w_en_char_RAM = 0;
        r_en_char_RAM = 0;
        address_char_RAM = 0;
        w_en_keyboard_IO = 0;
        r_en_keyboard_IO = 0;
        address_keyboard_IO = 0;

        if(address <= 16'h000FF) begin  // Memory location for program RAM
            w_en_config_ROM = w_en;
            r_en_config_ROM = r_en;
            address_config_ROM = address;
        end

        else if(address <= 16'hEBFF) begin  // Memory location for char RAM
            w_en_program_RAM = w_en;
            r_en_program_RAM = r_en;
            address_program_RAM = address; 
            // program ram is mapped directly to the actual address range, i.e. starting from index 0x00FF.
        end

        else if(address <= 16'hFFEF) begin
            w_en_char_RAM = w_en;
            r_en_char_RAM = r_en;
            address_char_RAM = address - 16'hEC00; // i sure hope vivado can optimize this
        end

        else begin
            w_en_keyboard_IO = w_en;
            r_en_keyboard_IO = r_en;
            address_keyboard_IO = {12'h000000, address[3:0]};
            //address_keyboard_IO = address - 16'hFFF0;
        end
    end

endmodule
