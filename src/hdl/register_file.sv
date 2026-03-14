`timescale 1ns/1ps
`include "reg_name.sv"
`include "exx_type.sv"

module register_file
(
    input  wire         clk,
    input  wire         reset,

    // exchange input
    input exx_type      exx,

    // register read ports
    input  reg_name     reg_a_sel,
    input  reg_name     reg_b_sel,
    output wire[15:0]   reg_a,
    output wire[15:0]   reg_b,

    // register write port
    input  reg_name     reg_w_sel,
    input  wire [15:0]  reg_w_data,
    input  wire         reg_w_en,

    // flags
    input  wire [5:0]   f_set,
    input  wire [5:0]   f_reset,
    input  wire [5:0]   f_toggle,
    input  wire         f_w_en, // write enable for flags. note that a reg write to f can still happen if f_w_en = 0
    output wire [5:0]   f
);
    reg [7:0] main_reg_set [0:7]; // In order A F B C D E H L
    reg [7:0] alt_reg_set [0:7]; // Same as above, but alternate bank

    /* verilator lint_off UNUSEDSIGNAL */ // ?????
    reg [15:0] special_reg_set [0:4]; // IR IX IY SP PC
    /* verilator lint_on UNUSEDSIGNAL */

    wire [7:0] internal_f_set;
    wire [7:0] internal_f_reset;
    wire [7:0] internal_f_toggle;


    // the stored version of f is 8 bits with two 'X' (unused) flags. The external value is only the 6 used bits
    assign f = {main_reg_set[1][7:6], main_reg_set[1][4], main_reg_set[1][2:0]};

    assign internal_f_set       = {f_set[5:4], 1'b0, f_set[3], 1'b0, f_set[2:0]};
    assign internal_f_reset     = {f_reset[5:4], 1'b0, f_reset[3], 1'b0, f_reset[2:0]};
    assign internal_f_toggle    = {f_toggle[5:4], 1'b0, f_toggle[3], 1'b0, f_toggle[2:0]};
    
    // reg_sel unused?
    // verilator lint_off UNUSEDSIGNAL
    function automatic[15:0] read_from_reg_file (reg_name reg_sel);
        case(reg_sel)
            ZERO:   read_from_reg_file = 16'h000;
            A:      read_from_reg_file={8'h00, main_reg_set[0]};
            F:      read_from_reg_file={8'h00, main_reg_set[1]};
            B:      read_from_reg_file={8'h00, main_reg_set[2]};
            C:      read_from_reg_file={8'h00, main_reg_set[3]};
            D:      read_from_reg_file={8'h00, main_reg_set[4]};
            E:      read_from_reg_file={8'h00, main_reg_set[5]};
            H:      read_from_reg_file={8'h00, main_reg_set[6]};
            L:      read_from_reg_file={8'h00, main_reg_set[7]};
            AF:     read_from_reg_file={main_reg_set[0], main_reg_set[1]};
            BC:     read_from_reg_file={main_reg_set[2], main_reg_set[3]};
            DE:     read_from_reg_file={main_reg_set[4], main_reg_set[5]};
            HL:     read_from_reg_file={main_reg_set[6], main_reg_set[7]};
            I:      read_from_reg_file={8'h00, special_reg_set[0][15:8]}; // I and R are stuck in the same special_reg_set entry
            R:      read_from_reg_file={8'h00, special_reg_set[0][7:0]};   
            IX:     read_from_reg_file=special_reg_set[1]; 
            IY:     read_from_reg_file=special_reg_set[2]; 
            SP:     read_from_reg_file=special_reg_set[3]; 
            PC:     read_from_reg_file=special_reg_set[4]; 
            default:read_from_reg_file = 16'hXXXX;
        endcase
    endfunction

    function void write_to_reg_file (reg_name reg_sel, reg[15:0] data);
        case(reg_sel)
            A:      main_reg_set[0] = data[7:0];
            F:      main_reg_set[1] = data[7:0];
            B:      main_reg_set[2] = data[7:0];
            C:      main_reg_set[3] = data[7:0];
            D:      main_reg_set[4] = data[7:0];
            E:      main_reg_set[5] = data[7:0];
            H:      main_reg_set[6] = data[7:0];
            L:      main_reg_set[7] = data[7:0];
            AF: begin // AF = 0x1234 => A = 0x12 and F = 0x34
                    main_reg_set[1] = data[7:0];
                    main_reg_set[0] = data[15:8];
            end
            BC: begin
                    main_reg_set[3] = data[7:0];
                    main_reg_set[2] = data[15:8];
            end
            DE: begin
                    main_reg_set[5] = data[7:0];
                    main_reg_set[4] = data[15:8];
            end
            HL: begin
                    main_reg_set[7] = data[7:0];
                    main_reg_set[6] = data[15:8];
            end
            I:      special_reg_set[0][15:8] = data[7:0];
            R:      special_reg_set[0][7:0] = data[7:0];   
            IX:     special_reg_set[1] = data; 
            IY:     special_reg_set[2] = data; 
            SP:     special_reg_set[3] = data; 
            PC:     special_reg_set[4] = data;
            default:;
        endcase
    endfunction
    // verilator lint_on UNUSEDSIGNAL

    // async reset. not sure if this is a good idea
    always_ff @(posedge reset or posedge clk) begin
        //reset
        if (reset) begin
            main_reg_set    <= '{default:8'h00};
            alt_reg_set     <= '{default:8'h00};
            special_reg_set <= '{default:16'h0000};

        // read/write and flag update
        end else begin
            reg_a <= read_from_reg_file(reg_a_sel);
            reg_b <= read_from_reg_file(reg_b_sel);

            if (reg_w_en == 1'b1) begin
                write_to_reg_file(reg_w_sel, reg_w_data);
            end

            if (f_w_en == 1'b1) begin
                //$display("doing flag stuff!");
                //$display("%b %b %b", internal_f_set, internal_f_reset, internal_f_toggle);
                //$display("%b", main_reg_set[1]);
                //$display("%b", main_reg_set[1] & ( ~ internal_f_reset));
                if (! (internal_f_set == 0)) main_reg_set[1] <= main_reg_set[1] | internal_f_set;
                if (! (internal_f_reset == 0)) main_reg_set[1] <= main_reg_set[1] & ( ~ internal_f_reset);
                if (! (internal_f_toggle == 0)) main_reg_set[1] <= main_reg_set[1] ^ internal_f_toggle;
            end
        end

        // exchange
        if (! (exx == EXX_NOP)) begin
            case(exx)
                EXX_DE_HL: begin
                    main_reg_set[4] <= main_reg_set[6]; // D <=> H
                    main_reg_set[6] <= main_reg_set[4];
                    main_reg_set[5] <= main_reg_set[7]; // E <=> L
                    main_reg_set[7] <= main_reg_set[5];
                end
                EXX_AF_AFp: begin
                    main_reg_set[0] <= alt_reg_set[0]; // A <=> A'
                    alt_reg_set[0]  <= main_reg_set[0];
                    main_reg_set[1] <= alt_reg_set[1]; // F <=> F'
                    alt_reg_set[1]  <= main_reg_set[1];
                end
                EXX_ALL: begin
                    main_reg_set <= alt_reg_set;
                    alt_reg_set <= main_reg_set;
                end
                default:;
            endcase
        end
    end
endmodule
