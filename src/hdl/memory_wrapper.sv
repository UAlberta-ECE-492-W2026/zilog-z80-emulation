`timescale 1ns/1ps

// the interface specifies the following:
//inputs 
// mem_data_mux_sel, 
// mem_mux_sel, 
// mem_addr_buff_en, 
// memory_out, (memory out from the datapath, really the data in for this module)
//outputs 
// memory_in, (aka data_out_8)
// instruction_in (aka data_out_32)
module memory_wrapper #(
)(
    c_to_dp_intf.memory_wrapper intf,
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[15:0] char_ram_address,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic[7:0] char_ram_data

    // AXI interface missing
);

    assign char_ram_data = 8'bXXXXXXXX;
endmodule
