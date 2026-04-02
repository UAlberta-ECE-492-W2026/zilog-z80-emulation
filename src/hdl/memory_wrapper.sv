//`timescale 1ns/1ps
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
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
)(

    c_to_dp_intf.memory_wrapper intf,

    // Char ram signals
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[15:0] char_ram_address,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic[7:0] char_ram_data

    // AXI
    /* verilator lint_off UNUSEDSIGNAL */
    `ifdef USE_AXI_KEYBOARD
    ,
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready
    `endif
    /* verilator lint_on UNUSEDSIGNAL */

    // debug
    `ifdef Z80_TOP_TESTING
    , // comma here so that if we don't use the ifdef the last port doesn't have a trailing comma
    input logic override_instruciton,
    input logic[31:0] override_instruciton_data,
    output logic[7:0] test_ram [0:7]
    `endif
);  
    wire [31:0] data_out_32;

    /* verilator lint_off UNUSEDSIGNAL */
    wire w_en_config_ROM;
    wire r_en_config_ROM;
    wire [15:0] address_config_ROM;
    wire [7:0] data_out_config_ROM;
    /* verilator lint_on UNUSEDSIGNAL */

    wire w_en_program_RAM;
    wire r_en_program_RAM;
    wire [15:0] address_program_RAM;
    wire [7:0] data_out_program_RAM;

    wire w_en_char_RAM;
    wire r_en_char_RAM;
    wire [15:0] address_char_RAM;
    wire [7:0] data_out_char_RAM;

    /* verilator lint_off UNUSEDSIGNAL */
    wire w_en_keyboard_IO;
    wire r_en_keyboard_IO;
    wire [15:0] address_keyboard_IO;
    wire [7:0] data_out_keyboard_IO;
    /* verilator lint_on UNUSEDSIGNAL */

    // mux outputs
    reg [15:0] address;
    reg [7:0] data_in;

    // mem data mux
    always_comb begin
        case(intf.mem_data_mux_sel)
            MEM_DATA_MUX_UPPER: data_in = intf.memory_out[15:8];
            MEM_DATA_MUX_LOWER: data_in = intf.memory_out[7:0];
            default: data_in = 8'h00;
        endcase
    end

    wire [15:0] mem_addr_buff_out;
    buffer #(16) mem_addr_buff (
        .in(intf.memory_out),
        .w(intf.mem_addr_buff_en),
        .clk(intf.clk),
        .reset(intf.reset),
        .out(mem_addr_buff_out)
    );

    // mem address mux
    always_comb begin
        case(intf.mem_mux_sel)
            MEM_MUX_BUFFERED: address = mem_addr_buff_out;
            MEM_MUX_BUFFERED_P1: address = mem_addr_buff_out + 1;
            MEM_MUX_UNBUFFERED: address = intf.memory_out;
            MEM_MUX_UNBUFFERED_P1: address = intf.memory_out + 1;
            default: address = 16'h0000;
        endcase
    end

    memory_decoder #() memory_decoder(
        .address(address),
        .w_en(intf.mem_w_en),
        .r_en(intf.mem_r_en),
        .w_en_config_ROM(w_en_config_ROM),
        .r_en_config_ROM(r_en_config_ROM),
        .address_config_ROM(address_config_ROM),
        .w_en_program_RAM(w_en_program_RAM),
        .r_en_program_RAM(r_en_program_RAM),
        .address_program_RAM(address_program_RAM),
        .w_en_char_RAM(w_en_char_RAM),
        .r_en_char_RAM(r_en_char_RAM),
        .address_char_RAM(address_char_RAM),
        .w_en_keyboard_IO(w_en_keyboard_IO),
        .r_en_keyboard_IO(r_en_keyboard_IO),
        .address_keyboard_IO(address_keyboard_IO)
    );
    
    // TODO: config ROM
    assign data_out_config_ROM = 8'h00;

    program_ram #()program_ram(
        .clk(intf.clk),
        .reset(intf.reset),
        .w_en(w_en_program_RAM),
        .r_en(r_en_program_RAM),
        .data_out_8(data_out_program_RAM),
        .data_out_32(data_out_32),
        .address(address_program_RAM),
        .data_in(data_in)
    );

    char_ram  #()char_ram (
        .clk(intf.clk),
        .data_out(data_out_char_RAM),
        .address(address_char_RAM),
        .w_en(w_en_char_RAM),
        .r_en(r_en_char_RAM),
        .data_in(data_in),
        .char_ram_address(char_ram_address),
        .char_ram_data(char_ram_data)
    );

    `ifdef USE_AXI_KEYBOARD
        axi_wrapper #() axi_wrapper(
        .clk(clk),
        .reset(reset),
        .char_ram_address(char_ram_address), 
        .char_ram_data(char_ram_data), 
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awprot(s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wstrb(s00_axi_wstrb),
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),
        .s00_axi_bresp(s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_arprot(s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rresp(s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready)
    );
    `else
    assign data_out_keyboard_IO = 8'h00;
    `endif

    // data_out combining (avoiding a tristate bus since verilator gets unhappy about that)
    always_comb begin
        `ifdef Z80_TOP_TESTING
        if (intf.mem_r_en && address <= 16'h000F) begin
            intf.memory_in = test_ram_data[test_mem_addr];
        end else if (r_en_config_ROM) begin
        `else
        if (r_en_config_ROM) begin
        `endif
            intf.memory_in = data_out_config_ROM;
        end else if (r_en_program_RAM) begin
            intf.memory_in = data_out_program_RAM;
        end else if (r_en_char_RAM) begin
            intf.memory_in = data_out_char_RAM;
        end else if (r_en_keyboard_IO) begin
            intf.memory_in = data_out_keyboard_IO;
        end else begin
            intf.memory_in = 8'h00;
        end
    end

    // optional test ram for use with the top level tb. 
    // aliased to every 8b chunk for writes. 
    `ifdef Z80_TOP_TESTING
    reg [7:0] test_ram_data [0:7];

    wire [2:0] test_mem_addr;
    assign test_mem_addr = address[2:0];
    assign test_ram = test_ram_data;

    always_ff @(posedge intf.clk) begin
        if (intf.reset == 1) begin
            test_ram_data <= '{default:8'h00};
        end else begin
            if (intf.mem_w_en) begin
                test_ram_data[test_mem_addr] <= data_in;
            end
        end
    end
    `endif

    // optional instruction override function for use with the top tb
    `ifdef Z80_TOP_TESTING
    assign intf.instruction_in = override_instruciton ? override_instruciton_data : data_out_32;
    `else
    assign intf.instruction_in = data_out_32;
    `endif

endmodule
