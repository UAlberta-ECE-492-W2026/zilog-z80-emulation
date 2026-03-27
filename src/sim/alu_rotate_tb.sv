`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_off UNUSEDSignal */
/* verilator lint_off UNUSEDSIGNAL */

task display_input_output_expected(
    input reg        en,
    input reg        carry_in,
    input reg [15:0] a,
    input reg [15:0] b,
    input alu_op     opcode,
    input reg [15:0] dout,
    input reg [15:0] expected_dout,
    input reg [5:0]  status_flag,
    input reg [5:0]  expected_flag
);
    $write("1'h%h | 1'h%h | 16'h%h | 16'h%h | %s | 16'h%h | 16'h%h | 6'b%b | 6'b%b",
        en, carry_in, a, b, opcode.name, dout, expected_dout, status_flag, expected_flag);
endtask

module alu_rotate_tb();

    reg        en;
    reg        carry_in;
    reg [15:0] a, b;
    alu_op     opcode;

    wire [15:0] dout;
    wire [5:0]  status_flag;

    reg [15:0] expected_dout;
    reg [5:0]  expected_flag;

    typedef struct {
        reg        en;
        reg        carry_in;
        reg [15:0] a;
        reg [15:0] b;
        alu_op     opcode;
        reg [15:0] expected_dout;
        reg [5:0]  expected_flag;
    } test_vector;

    test_vector testvectors[];

    initial begin: file_setup
        $dumpfile("out/sim/alu_rotate_tb.vcd");
        $dumpvars();
    end

    initial begin: test_definition
        testvectors = new [14];

        // =========================================================
        // RL tests (use low byte only, high byte = 0)
        // flag format: [5]=S [4]=Z [3]=H [2]=P/V [1]=N [0]=C
        // =========================================================
        testvectors[0]  = '{1, 0, 16'h0081, 16'h0000, ALU_RL,  16'h0002, 6'b000001};
        testvectors[1]  = '{1, 1, 16'h0040, 16'h0000, ALU_RL,  16'h0081, 6'b100100};
        testvectors[2]  = '{1, 0, 16'h0000, 16'h0000, ALU_RL,  16'h0000, 6'b010100};
        testvectors[3]  = '{1, 1, 16'h00FF, 16'h0000, ALU_RL,  16'h00FF, 6'b100101};

        // =========================================================
        // RR tests (use low byte only, high byte = 0)
        // =========================================================
        testvectors[4]  = '{1, 0, 16'h0003, 16'h0000, ALU_RR,  16'h0001, 6'b000001};
        testvectors[5]  = '{1, 1, 16'h0002, 16'h0000, ALU_RR,  16'h0081, 6'b100100};
        testvectors[6]  = '{1, 0, 16'h0000, 16'h0000, ALU_RR,  16'h0000, 6'b010100};
        testvectors[7]  = '{1, 0, 16'h00FF, 16'h0000, ALU_RR,  16'h007F, 6'b000001};

        // =========================================================
        // RLD tests
        // a[7:0] = A
        // b[7:0] = (HL)
        // dout[15:8] = new A, dout[7:0] = new (HL)
        // =========================================================
        testvectors[8]  = '{1, 0, 16'h0012, 16'h0034, ALU_RLD, 16'h1342, 6'b000000};
        testvectors[9]  = '{1, 1, 16'h00AB, 16'h00CD, ALU_RLD, 16'hACDB, 6'b100101};
        testvectors[10] = '{1, 0, 16'h0010, 16'h0000, ALU_RLD, 16'h1000, 6'b000000};

        // =========================================================
        // RRD tests
        // =========================================================
        testvectors[11] = '{1, 0, 16'h0012, 16'h0034, ALU_RRD, 16'h1423, 6'b000100};
        testvectors[12] = '{1, 1, 16'h00F0, 16'h000F, ALU_RRD, 16'hFF00, 6'b100101};
        testvectors[13] = '{1, 0, 16'h0000, 16'h0000, ALU_RRD, 16'h0000, 6'b010100};
    end

    initial begin
        $display("en|cin|        a |        b |    op |     dout | expected | flags | expected |");

        for (int i = 0; i < $size(testvectors); ++i) begin
            #10;
            en            = testvectors[i].en;
            carry_in      = testvectors[i].carry_in;
            a             = testvectors[i].a;
            b             = testvectors[i].b;
            opcode        = testvectors[i].opcode;
            expected_dout = testvectors[i].expected_dout;
            expected_flag = testvectors[i].expected_flag;
            #1;
        end

        #10 $finish;
    end

    always begin
        #11 display_input_output_expected(en, carry_in, a, b, opcode, dout, expected_dout, status_flag, expected_flag);
        if ((dout == expected_dout) && (status_flag == expected_flag)) $display(" | PASS");
        else $display(" | FAIL");
    end

    alu #(
        .alu_width(16)
    ) dut (
        .out(dout),
        .enable(en),
        .a(a),
        .b(b),
        .opcode(opcode),
        .status_flag(status_flag),
        .carry_in(carry_in)
    );

endmodule
