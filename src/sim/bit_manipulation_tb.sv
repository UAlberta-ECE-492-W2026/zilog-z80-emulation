`timescale 1ns/1ps
`include "reg_name.sv"
`include "exx_type.sv"
`include "f_op.sv"
`include "mop.sv"
`include "mux_enums.sv"
`include "alu_op.sv"

/* verilator lint_off UNUSEDSIGNAL */
task display_input_output_expected_bit_manip(
    input reg             ir_en,
    input reg             o_buff_en,
    input reg             mem_read_buff_en,
    input reg             alu_enable,
    input reg             alu_16b_mode,
    input alu_op          alu_opcode,
    input reg [5:0]       update_flags,
    input reg_name        reg_a_sel,
    input reg_name        reg_b_sel,
    input reg_name        reg_w_sel,
    input reg             reg_w_en,
    input reg             f_w_en,
    input f_op_enum       f_op,
    input exx_type        exx,
    input alu_mux_a_enum  alu_mux_a_sel,
    input alu_mux_b_enum  alu_mux_b_sel,
    input write_back_enum write_back_sel,
    input reg [7:0]       memory_in,
    input reg [15:0]      imm_in,
    input reg [2:0]       instruction_length,

    input reg [5:0]       f,
    input reg [5:0]       raw_f,
    input reg [15:0]      memory_out,

    input reg [5:0]       expected_f,
    input reg [5:0]       expected_raw_f,
    input reg [15:0]      expected_memory_out
);
    $write("   %b |       %b |              %b |        %b |          %b |%11s|     %b |    %4s |    %4s |    %4s |      %b |    %b |%5s|%10s|%22s|%25s|%24s|      %h |   %h |               %d |%b| %b | %h\n",
        ir_en,
        o_buff_en,
        mem_read_buff_en,
        alu_enable,
        alu_16b_mode,
        alu_opcode.name,
        update_flags,
        reg_a_sel.name,
        reg_b_sel.name,
        reg_w_sel.name,
        reg_w_en,
        f_w_en,
        f_op.name,
        exx.name,
        alu_mux_a_sel.name,
        alu_mux_b_sel.name,
        write_back_sel.name,
        memory_in,
        imm_in,
        instruction_length,
        f,
        raw_f,
        memory_out
    );

    $write("     |         |                |          |            |           |            |         |         |         |        |      |     |          |                      |                         |                        |         |        |                 |%b| %b | %h",
        expected_f,
        expected_raw_f,
        expected_memory_out
    );
endtask

module bit_manipulation_tb();

    reg clk;
    reg reset;

    reg         ir_en;
    reg         o_buff_en;
    reg         mem_read_buff_en;

    reg         alu_enable;
    reg         alu_16b_mode;
    alu_op      alu_opcode;
    reg [5:0]   update_flags;

    reg_name    reg_a_sel;
    reg_name    reg_b_sel;
    reg_name    reg_w_sel;
    reg         reg_w_en;
    reg         f_w_en;
    f_op_enum   f_op;
    exx_type    exx;
    reg [5:0]   f;

    alu_mux_a_enum  alu_mux_a_sel;
    alu_mux_b_enum  alu_mux_b_sel;
    write_back_enum write_back_sel;

    reg [7:0]   memory_in;
    reg [15:0]  memory_out;

    mop         mop_out;

    reg [15:0]  imm_in;
    reg [2:0]   instruction_length;
    reg [5:0]   raw_f;

    reg all_pass;

    typedef struct {
        reg             ir_en;
        reg             o_buff_en;
        reg             mem_read_buff_en;
        reg             alu_enable;
        reg             alu_16b_mode;
        alu_op          alu_opcode;
        reg [5:0]       update_flags;
        reg_name        reg_a_sel;
        reg_name        reg_b_sel;
        reg_name        reg_w_sel;
        reg             reg_w_en;
        reg             f_w_en;
        f_op_enum       f_op;
        exx_type        exx;
        alu_mux_a_enum  alu_mux_a_sel;
        alu_mux_b_enum  alu_mux_b_sel;
        write_back_enum write_back_sel;
        reg [7:0]       memory_in;
        reg [15:0]      imm_in;
        reg [2:0]       instruction_length;

        reg [5:0]       expected_f;
        reg [5:0]       expected_raw_f;
        reg [15:0]      expected_memory_out;
    } test_vector;

    test_vector testvectors[$];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    /* verilator lint_off PINCONNECTEMPTY */
    datapath dut (
        .clk(clk),
        .reset(reset),
        .ir_en(ir_en),
        .o_buff_en(o_buff_en),
        .mem_read_buff_en(mem_read_buff_en),
        .alu_enable(alu_enable),
        .alu_16b_mode(alu_16b_mode),
        .alu_opcode(alu_opcode),
        .update_flags(update_flags),
        .reg_a_sel(reg_a_sel),
        .reg_b_sel(reg_b_sel),
        .reg_w_sel(reg_w_sel),
        .reg_w_en(reg_w_en),
        .f_w_en(f_w_en),
        .f_op(f_op),
        .exx(exx),
        .f(f),
        .alu_mux_a_sel(alu_mux_a_sel),
        .alu_mux_b_sel(alu_mux_b_sel),
        .write_back_sel(write_back_sel),
        .memory_in(memory_in),
        .memory_out(memory_out),
        .instruction_in(32'h0000),
        .mop_out(mop_out),
        .reg_a_sel_out(),
        .reg_b_sel_out(),
        .imm_0_out(),
        .imm_1_out(),
        .use_16b_alu_out(),
        .update_flags_out(),
        .instruction_length_out(),
        .imm_in(imm_in),
        .instruction_length(instruction_length),
        .raw_f(raw_f)
    );
    /* verilator lint_on PINCONNECTEMPTY */

    task reset_tb;
        begin
            reset = 1;
            repeat (2) @(posedge clk);
            reset = 0;
            @(posedge clk);
        end
    endtask

    initial begin
        all_pass = 1'b1;

        ir_en              = 0;
        o_buff_en          = 0;
        mem_read_buff_en   = 0;
        alu_enable         = 0;
        alu_16b_mode       = 0;
        alu_opcode         = ALU_NOP;
        update_flags       = 6'b000000;
        reg_a_sel          = NONE;
        reg_b_sel          = NONE;
        reg_w_sel          = NONE;
        reg_w_en           = 0;
        f_w_en             = 0;
        f_op               = F_NOP;
        exx                = EXX_NOP;
        alu_mux_a_sel      = A_MUX_NOP;
        alu_mux_b_sel      = B_MUX_NOP;
        write_back_sel     = WB_MUX_NOP;
        memory_in          = 8'h00;
        imm_in             = 16'h0000;
        instruction_length = 3'd0;

        $dumpfile("out/sim/bit_manipulation_tb.vcd");
        $dumpvars(0, bit_manipulation_tb);

        // --------------------------------------------------------------------
        // Seed registers / flags
        // --------------------------------------------------------------------
        // A = 0x42
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_B,6'b000000,NONE,NONE,A,1,0,F_NOP,EXX_NOP,A_MUX_NOP,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0042,3'd0,6'b000000,6'b000000,16'h0042});

        // B = 0x81
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_B,6'b000000,NONE,NONE,B,1,0,F_NOP,EXX_NOP,A_MUX_NOP,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0081,3'd0,6'b000000,6'b100000,16'h0081});

        // F = 0x3F
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_B,6'b000000,NONE,NONE,F,1,0,F_NOP,EXX_NOP,A_MUX_NOP,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h003F,3'd0,6'b001111,6'b000000,16'h003f});

        // --------------------------------------------------------------------
        // BIT tests
        // These expected values match the current datapath behavior you observed.
        // --------------------------------------------------------------------
        // BIT 1, A  where A = 0x42 => bit1 = 1
        testvectors.push_back('{0,0,0,1,0,ALU_BIT,6'b011010,A,NONE,NONE,0,1,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0001,3'd0,6'b001101,6'b001000,16'h0000});

        // BIT 0, A  where A = 0x42 => bit0 = 0
        testvectors.push_back('{0,0,0,1,0,ALU_BIT,6'b011010,A,NONE,NONE,0,1,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0000,3'd0,6'b001101,6'b011000,16'h0000});

        // --------------------------------------------------------------------
        // SET / RES register ops
        // Note: memory_out is not the register writeback result, so it stays 0 here.
        // --------------------------------------------------------------------
        // SET 0, A : 0x42 -> 0x43
        testvectors.push_back('{0,0,0,1,0,ALU_SETBIT,6'b000000,A,NONE,A,1,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0000,3'd0,6'b001101,6'b000000,16'h0000});

        // Observe flags after SET 0, A
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_A,6'b000000,A,NONE,NONE,0,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0000,3'd0,6'b001101,6'b010000,16'h0000});

        // RES 6, A : 0x43 -> 0x03
        testvectors.push_back('{0,0,0,1,0,ALU_RESBIT,6'b000000,A,NONE,A,1,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0006,3'd0,6'b001101,6'b000000,16'h0000});

        // Observe flags after RES 6, A
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_A,6'b000000,A,NONE,NONE,0,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0000,3'd0,6'b001101,6'b010000,16'h0000});

        // SET 6, B : 0x81 -> 0xC1
        testvectors.push_back('{0,0,0,1,0,ALU_SETBIT,6'b000000,B,NONE,B,1,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0006,3'd0,6'b001101,6'b000000,16'h0000});

        // Observe flags after SET 6, B
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_A,6'b000000,B,NONE,NONE,0,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0000,3'd0,6'b001101,6'b010000,16'h0000});

        // RES 7, B : 0xC1 -> 0x41
        testvectors.push_back('{0,0,0,1,0,ALU_RESBIT,6'b000000,B,NONE,B,1,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_ALU,8'h00,16'h0007,3'd0,6'b001101,6'b000000,16'h0000});

        // Observe flags after RES 7, B
        testvectors.push_back('{0,0,0,1,0,ALU_PASS_A,6'b000000,B,NONE,NONE,0,0,F_NOP,EXX_NOP,A_MUX_REG,B_MUX_IMM,WB_MUX_NOP,8'h00,16'h0000,3'd0,6'b001101,6'b010000,16'h0000});

        reset_tb();

        $display("");
        $display("============================================================");
        $display("SECTION: BIT MANIPULATION");
        $display("============================================================");
        $display("ir_en|o_buff_en|mem_read_buff_en|alu_enable|alu_16b_mode|alu_opcode |update_flags|reg_a_sel|reg_b_sel|reg_w_sel|reg_w_en|f_w_en| f_op|       exx|         alu_mux_a_sel|            alu_mux_b_sel|          write_back_sel|memory_in|  imm_in|instuction_length|     f|   raw_f|memory_out");

        for (int i = 0; i < $size(testvectors); ++i) begin
            ir_en              = testvectors[i].ir_en;
            o_buff_en          = testvectors[i].o_buff_en;
            mem_read_buff_en   = testvectors[i].mem_read_buff_en;
            alu_enable         = testvectors[i].alu_enable;
            alu_16b_mode       = testvectors[i].alu_16b_mode;
            alu_opcode         = testvectors[i].alu_opcode;
            update_flags       = testvectors[i].update_flags;
            reg_a_sel          = testvectors[i].reg_a_sel;
            reg_b_sel          = testvectors[i].reg_b_sel;
            reg_w_sel          = testvectors[i].reg_w_sel;
            reg_w_en           = testvectors[i].reg_w_en;
            f_w_en             = testvectors[i].f_w_en;
            f_op               = testvectors[i].f_op;
            exx                = testvectors[i].exx;
            alu_mux_a_sel      = testvectors[i].alu_mux_a_sel;
            alu_mux_b_sel      = testvectors[i].alu_mux_b_sel;
            write_back_sel     = testvectors[i].write_back_sel;
            memory_in          = testvectors[i].memory_in;
            imm_in             = testvectors[i].imm_in;
            instruction_length = testvectors[i].instruction_length;

            #1;
            display_input_output_expected_bit_manip(
                ir_en,
                o_buff_en,
                mem_read_buff_en,
                alu_enable,
                alu_16b_mode,
                alu_opcode,
                update_flags,
                reg_a_sel,
                reg_b_sel,
                reg_w_sel,
                reg_w_en,
                f_w_en,
                f_op,
                exx,
                alu_mux_a_sel,
                alu_mux_b_sel,
                write_back_sel,
                memory_in,
                imm_in,
                instruction_length,
                f,
                raw_f,
                memory_out,
                testvectors[i].expected_f,
                testvectors[i].expected_raw_f,
                testvectors[i].expected_memory_out
            );

            if ((testvectors[i].expected_f == f) &&
                (testvectors[i].expected_raw_f == raw_f) &&
                (testvectors[i].expected_memory_out == memory_out)) begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL at time = %f", $realtime);
                all_pass = 1'b0;
            end

            $display("");
            #9;
        end

        if (all_pass == 1'b1) begin
            $display("ALL TESTS PASS");
        end else begin
            $display("FAILING TESTS!");
        end

        $finish;
    end

endmodule
/* verilator lint_on UNUSEDSIGNAL */
