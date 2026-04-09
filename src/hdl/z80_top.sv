`timescale 1ns/1ps


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
    output logic [3:0] ja,
    output logic led6_r,
    output logic led6_g,
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

    c_to_dp_intf intf();
    logic slow_clk;
    
    `ifdef USE_SLOW_CLOCK
    assign intf.clk = slow_clk;
    `else
    assign intf.clk = clk;
    `endif
    assign intf.reset =  buttons[0];
    assign led6_r = intf.clk;
    assign led6_g = intf.reset;
    
    reg [31:0]div_count;
    always_ff @(posedge clk) begin 
        if (intf.reset) begin
            div_count <= 0;
            slow_clk <= 0;
        end else if (div_count == 1) begin// 40000000 here is good for debugging
            div_count <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            div_count <= div_count + 1;
        end
    end

    reg [7:0] byte_to_display;

    // select byte to show on the display
    always_comb begin
        byte_to_display = 8'h00;
        if (switches == 4'b0000) begin
            byte_to_display = intf.current_state[7:0];
        end else if (switches == 4'b0001) begin
            byte_to_display = intf.mop_out[7:0];
        end else if (switches == 4'b0010) begin
            byte_to_display = memory_mapped_display_byte;
        end else if (switches == 4'b0011) begin
            byte_to_display = intf.memory_in;
        end else if (switches == 4'b0100) begin // PC
            if (buttons[2] == 0) begin
                byte_to_display = special_reg_set[4][7:0];
            end else begin
                byte_to_display = special_reg_set[4][15:8];
            end
        end else if (switches == 4'b0101) begin // SP
            if (buttons[2] == 0) begin
                byte_to_display = special_reg_set[3][7:0];
            end else begin
                byte_to_display = special_reg_set[3][15:8];
            end
        end else begin
            byte_to_display = 8'b10101010;
        end
    end
    assign LEDs = byte_to_display[3:0];
    
    logic ssd_clk;
    reg [31:0]ssd_display_count;
    always_ff @(posedge clk) begin
        if (intf.reset) begin
            ssd_display_count <= 0;
            ssd_clk <= 0;
        end else if (ssd_display_count == 400000) begin
            ssd_clk <= ~ssd_clk;
            ssd_display_count <= 0;
        end else begin
            ssd_display_count <= ssd_display_count + 1;
        end   
    end

    // the byte -> seven segment display mapping
    // found this function on github https://github.com/SirSerow/Zybo-Z7_FPGA_Verilog_Training/blob/master/kitchen_timer.srcs/sources_1/new/top_board_adapter.v
    /* verilator lint_off UNUSEDSIGNAL */
    function [6:0] decode_digit(input [3:0] digit);
        case (digit)
            4'h0: decode_digit = 7'b011_1111;
            4'h1: decode_digit = 7'b000_0110;
            4'h2: decode_digit = 7'b101_1011;
            4'h3: decode_digit = 7'b100_1111;
            4'h4: decode_digit = 7'b110_0110;
            4'h5: decode_digit = 7'b110_1101;
            4'h6: decode_digit = 7'b111_1101;
            4'h7: decode_digit = 7'b000_0111;
            4'h8: decode_digit = 7'b111_1111;
            4'h9: decode_digit = 7'b110_1111;
            4'hA: decode_digit = 7'b111_0111;
            4'hb: decode_digit = 7'b111_1100;
            4'hC: decode_digit = 7'b011_1001;
            4'hd: decode_digit = 7'b101_1110;
            4'hE: decode_digit = 7'b111_1001;
            4'hF: decode_digit = 7'b111_0001;
            default: decode_digit = 7'b000_0000;
        endcase
    endfunction
    /* verilator lint_on UNUSEDSIGNAL */

    always_comb begin
        if (ssd_clk) begin
            je[3] = 1'b0;
            {je[2:0], ja[3:0]} = decode_digit(byte_to_display[3:0]);
        end else begin
            je[3] = 1'b1;
            {je[2:0], ja[3:0]} = decode_digit(byte_to_display[7:4]);
        end
    end
    
    // Clock divider to drive the vga
    logic [2:0] pixel_div_count;
    logic pixel_clk;
    //assign pixel_clk = clk;

    always_ff @(posedge clk) begin
        if (intf.reset) begin
            pixel_div_count <= 0;
            pixel_clk <= 0;
        end else if (pixel_div_count == 0) begin
            pixel_div_count <= 0;
            pixel_clk <= ~pixel_clk;
        end else begin
            pixel_div_count <= pixel_div_count + 1;
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
        .pixel_clk(pixel_clk),
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
