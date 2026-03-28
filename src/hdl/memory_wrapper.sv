//`timescale 1ns/1ps
`include "char_ram.sv"
`include "program_ram.sv"

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

    // Char ram signals
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[15:0] char_ram_address,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic[7:0] char_ram_data,

    // AXI interface missing
    input logic axi_data_in,
    input logic axi_ready,
    input logic axi_valid

    // debug
    `ifdef Z80_TOP_TESTING
    , // comma here so that if we don't use the ifdef the last port doesn't have a trailing comma
    input logic override_instruciton,
    input logic[31:0] override_instruciton_data,
    output logic[7:0] test_ram [0:7]
    `endif
);  
    wire [31:0] data_out_32;
    
    char_ram  #()char_ram (
        .clk(intf.clk),
        .data_out(intf.memory_in),
        .address(char_ram_address),
        .w_en(intf.mem_w_en),
        .data_in(intf.memory_out)
    );

    program_ram #()program_ram(
        .clk(intf.clk),
        .reset(intf.reset),
        .w_en(intf.mem_w_en),
        .r_en(intf.mem_r_en),
        .data_out(intf.memory_in),
        .address(char_ram_address),
        .w_en(intf.mem_w_en),
        .data_in(intf.memory_out)
    )

    /*// placeholders
    assign data_out_32 = 32'hXXXXXXXX;
    assign char_ram_data = 8'hXX;

    `ifdef Z80_TOP_TESTING
    assign intf.instruction_in = override_instruciton ? override_instruciton_data : data_out_32;

    // placeholder
    assign test_ram = '{default:8'h00};
    `else
    assign intf.instruction_in = data_out_32;
    `endif*/

endmodule
