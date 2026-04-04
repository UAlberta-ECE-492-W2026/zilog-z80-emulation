`timescale 1ns/1ps

`define Z80_REGISTER_FILE_DEBUG

module z80_top #(
)(
    // display driving outputs
    output logic hsync,            //! horizontal sync (active LOW)
    output logic vsync,            //! vertical sync (active LOW)
    output logic [3:0] red,        //! red channel (4-bit)
    output logic [3:0] green,      //! green channel (4-bit)
    output logic [3:0] blue,        //! blue channel (4-bit)

    // debug inputs and outputs. TODO: attach these to something
    /* verilator lint_off UNUSEDSIGNAL */
    input logic[3:0] buttons,
    input logic[3:0] switches,
    output logic[3:0] LEDs,
    output logic [3:0] je,
    output logic [3:0] jd,
    /* verilator lint_on UNUSEDSIGNAL */

    // clock
    input logic clk

    // AXI interface missing
); 
    /* verilator lint_off UNUSEDSIGNAL */
    logic [7:0] main_reg_set [0:7];
    logic [15:0] special_reg_set [0:4];
    /* verilator lint_on UNUSEDSIGNAL */

    logic[15:0] char_ram_address;
    logic[7:0] char_ram_data;

    logic[7:0] memory_mapped_display_byte;

    assign LEDs = memory_mapped_display_byte[3:0];

    c_to_dp_intf intf();
    //assign intf.clk = clk;
    assign intf.clk = buttons[1];
    assign intf.reset =  buttons[0];

    reg [7:0] byte_to_display;

    // select byte to show on the display
    always_comb begin
        byte_to_display = 8'h00;
        if (switches == 4'b0000) begin
            byte_to_display = intf.current_state[7:0];
        end else if (switches == 4'b0001) begin
            if (buttons[2] == 0) begin
                byte_to_display = special_reg_set[4][7:0];
            end else begin
                byte_to_display = special_reg_set[4][15:8];
            end
        end else if (switches == 4'b0010) begin
            byte_to_display = intf.mop_out[7:0];
        end else if (switches == 4'b0011) begin
            byte_to_display = memory_mapped_display_byte;
        end
    end

    // the byte -> seven segment display mapping
    // found this function on github https://github.com/SirSerow/Zybo-Z7_FPGA_Verilog_Training/blob/master/kitchen_timer.srcs/sources_1/new/top_board_adapter.v
    /* verilator lint_off UNUSEDSIGNAL */
    function [6:0] decode_digit(input [3:0] digit);
        case (digit)
            4'd0: decode_digit = 7'b011_1111;
            4'd1: decode_digit = 7'b000_0110;
            4'd2: decode_digit = 7'b101_1011;
            4'd3: decode_digit = 7'b100_1111;
            4'd4: decode_digit = 7'b110_0110;
            4'd5: decode_digit = 7'b110_1101;
            4'd6: decode_digit = 7'b111_1101;
            4'd7: decode_digit = 7'b000_0111;
            4'd8: decode_digit = 7'b111_1111;
            4'd9: decode_digit = 7'b110_1111;
            default: decode_digit = 7'b000_0000;
        endcase
    endfunction
    /* verilator lint_on UNUSEDSIGNAL */

    always_comb begin
        if (buttons[3]) begin
            je[3] = 1'b0;
            {je[2:0], jd[3:0]} = decode_digit(byte_to_display[7:4]);
        end else begin
            je[3] = 1'b1;
            {je[2:0], jd[3:0]} = decode_digit(byte_to_display[3:0]);
        end
    end

    controller #() controller (intf);
    controller_next_state next_state_logic(.ctrl_intf(intf));
    controller_output output_logic(.intf(intf));
    datapath #() datapath (
        .intf(intf), 
        .debug_main_reg_set(main_reg_set), 
        .debug_special_reg_set(special_reg_set)
    );

    memory_wrapper #() memory_wrapper(
        .intf(intf), 
        .char_ram_address(char_ram_address), 
        .char_ram_data(char_ram_data),
        .memory_mapped_display_byte(memory_mapped_display_byte)
    );

    vga_out #() vga_out(
        .clk(clk),
        .reset(buttons[0]),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue),
        .char_ram_address(char_ram_address),
        .char_ram_data(char_ram_data)
    );
endmodule
