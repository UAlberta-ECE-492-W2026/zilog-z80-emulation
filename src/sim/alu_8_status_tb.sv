`timescale 1ns/1ps
`include "alu_op.sv"

/* verilator lint_off UNUSEDSignal */
/* verilator lint_off UNUSEDSIGNAL */
task display_input_output_expected(
    input reg en,
    input reg carry_in,
    input reg [7:0] a,
    input reg [7:0] b,
    input alu_op opcode,
    input reg [5:0] status_flag,
    input reg [5:0] expected
);
    $write("1'h%h | 1'h%h | 8'h%h | 8'h%h | %s | 6'b%b | 6'b%b",
        en, carry_in, a, b, opcode.name, status_flag, expected);
endtask

module alu_8_status_tb();

    reg en;
    reg [7:0] a, b;
    alu_op opcode;
    reg carry_in;

    wire [7:0] dout;
    wire [5:0] status_flag;
    reg [5:0] expected;

    typedef struct {
        reg en;
        reg [7:0] a;
        reg [7:0] b;
        alu_op opcode;
        reg [5:0] expected;
        reg carry_in;
    } test_vector;

    test_vector testvectors[];

    initial begin: file_setup
        $dumpfile("out/sim/alu_8_status_tb.vcd");
        $dumpvars();
    end

    initial begin: test_definition
        testvectors = new [26];

        // ADD
        testvectors[0]  = '{1, 8'd7,  8'd7,  ALU_ADD, 6'b000000, 0};
        testvectors[1]  = '{1, 8'hFF, 8'd1,  ALU_ADD, 6'b011001, 0};

        // SUB
        testvectors[2]  = '{1, 8'd7,  8'd7,  ALU_SUB, 6'b010010, 0};
        testvectors[3]  = '{1, 8'd0,  8'd1,  ALU_SUB, 6'b101011, 0};

        // AND
        testvectors[4]  = '{1, 8'h0D, 8'd7,  ALU_AND, 6'b001000, 0};

        // OR
        testvectors[5]  = '{1, 8'hCB, 8'h2B, ALU_OR,  6'b101000, 0};

        // XOR
        testvectors[6]  = '{1, 8'd7,  8'd7,  ALU_XOR, 6'b010000, 0};

        // SLL
        testvectors[7]  = '{1, 8'h07, 8'd3,  ALU_SLL, 6'b000000, 0};
        testvectors[8]  = '{1, 8'h0F, 8'd6,  ALU_SLL, 6'b000101, 0};

        // SRL
        testvectors[9]  = '{1, 8'hCA, 8'd3,  ALU_SRL, 6'b000000, 0};
        testvectors[10] = '{1, 8'hCA, 8'd8,  ALU_SRL, 6'b000101, 0};

        // SLA
        testvectors[11] = '{1, 8'h07, 8'd3,  ALU_SLA, 6'b000000, 0};
        testvectors[12] = '{1, 8'h0F, 8'd6,  ALU_SLA, 6'b000101, 0};

        // SRA
        testvectors[13] = '{1, 8'hCA, 8'd3,  ALU_SRA, 6'b000100, 0};
        testvectors[14] = '{1, 8'hCA, 8'd8,  ALU_SRA, 6'b000101, 0};

        // ROL
        testvectors[15] = '{1, 8'hCA, 8'd3,  ALU_ROL, 6'b000100, 0};

        // ROR
        testvectors[16] = '{1, 8'hCA, 8'd3,  ALU_ROR, 6'b000100, 0};

        // 1 + 2 + 0 = 3
        testvectors[17] = '{1, 8'h01, 8'h02, ALU_ADC, 6'b000000, 0};

        // 0x0F + 0 + carry = 0x10
        testvectors[18] = '{1, 8'h0F, 8'h00, ALU_ADC, 6'b001000, 1};

        // 0xFF + 0 + carry = 0x00 (carry out)
        testvectors[19] = '{1, 8'hFF, 8'h00, ALU_ADC, 6'b011001, 1};

        // 5 - 2 - 0 = 3
        testvectors[20] = '{1, 8'h05, 8'h02, ALU_SBC, 6'b000010, 0};

        // 0x10 - 0 - 1 = 0x0F
        testvectors[21] = '{1, 8'h10, 8'h00, ALU_SBC, 6'b001010, 1};

        // 0x00 - 1 - 1 = 0xFE (borrow + negative)
        testvectors[22] = '{1, 8'h00, 8'h01, ALU_SBC, 6'b101011, 1};

        testvectors[23] = '{0, 8'h00, 8'h00, ALU_NOP, 6'b000000, 0};
        testvectors[24] = '{0, 8'h00, 8'h00, ALU_NOP, 6'b000000, 0};
        testvectors[25] = '{0, 8'h00, 8'h00, ALU_NOP, 6'b000000, 0};
    end

    initial begin
        $display("en|cin|   a |   b |   op | flags | expected |");

        for (int i = 0; i < $size(testvectors); ++i) begin
            #10;
            en       = testvectors[i].en;
            a        = testvectors[i].a;
            b        = testvectors[i].b;
            opcode   = testvectors[i].opcode;
            expected = testvectors[i].expected;
            carry_in = testvectors[i].carry_in;
            #1;
        end

        #10 $finish;
    end

    always begin
        #11 display_input_output_expected(en, carry_in, a, b, opcode, status_flag, expected);
        if (status_flag == expected) $display(" | PASS");
        else $display(" | FAIL");
    end

    alu #(
        .alu_width(8)
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
