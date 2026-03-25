`timescale 1ns/1ps
// Memory map decoder
// This module selects between the ROM and the RAM(s)
module memory_decoder
(

    // TODO: remove ROM and make it to spec of lucid chart and remove chip select
    input logic [15:0] address,  // Address bus for memory Read/Write
    input logic w_en,  // Write enable control for memory
    input logic r_en,  // Read enable control for memory

    output logic w_en_char_RAM,  // Write enable for the RAM
    output logic r_en_char_RAM,  // Read enable for the RAM

    output logic w_en_program_RAM,
    output logic r_en_program_RAM,

    output logic w_en_IO,
    output logic r_en_IO
);

always_comb begin

    w_en_char_RAM = 0;
    r_en_char_RAM = 0;
    w_en_program_RAM = 0;
    r_en_program_RAM = 0;
    w_en_IO = 0;
    r_en_IO = 0;


        if(address <= 16'h06FF) begin  // Memory location for program RAM
            if (w_en) w_en_program_RAM = 1;
            if (r_en) r_en_program_RAM = 1;
        end

        else if(address <= 16'h0CFF) begin  // Memory location for char RAM
            if (w_en) w_en_char_RAM = 1;
            if (r_en) r_en_char_RAM = 1;
        end

        else if(address <= 16'h0DFF) begin
            if (w_en) w_en_IO = 1;
            if (r_en) r_en_IO = 1;
        end

end

endmodule
