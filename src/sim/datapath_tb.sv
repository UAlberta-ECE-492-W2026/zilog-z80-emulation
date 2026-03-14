`timescale 1ns/1ps
`include "reg_name.sv"
`include "exx_type.sv"
`include "f_op.sv"
`include "mop.sv"
`include "mux_enums.sv"
`include "alu_op.sv"

/* verilator lint_off UNUSEDSignal */
task display_input_output_expected_datapath(input 
        reg ir_en,
        reg o_buff_en,
        reg alu_enable,
        reg alu_16b_mode,
        alu_op alu_opcode,
        reg[5:0] update_flags,
        reg_name reg_a_sel,
        reg_name reg_b_sel,
        reg_name reg_w_sel,
        reg reg_w_en,
        reg f_w_en,
        f_op_enum f_op,
        exx_type exx,
        alu_mux_a_enum alu_mux_a_sel,
        alu_mux_b_enum alu_mux_b_sel,
        write_back_enum write_back_sel,
        reg [7:0] memory_in,
        reg [15:0] imm_in,
        reg [2:0] instruction_length,

        //outputs
        reg[5:0] f, 
        reg[5:0] raw_f_buffered,
        reg [15:0] memory_out, 

        //expected outputs
        reg[5:0] expected_f, 
        reg[5:0] expected_raw_f_buffered,
        reg [15:0] expected_memory_out
    );

    // TODO: format this string nicely like in register_file.tb
    $write("%b | %b | %b | %b | %s | %b | %s | %s | %s | %b | %b  | %s | %s | %s | %s | %s | %h | %h | %d | %b | %b | %h\n",
        ir_en,
        o_buff_en,
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
        memory_out, 
        raw_f_buffered
    );

    $write("          | %b | %b | %h", 
        expected_f, 
        expected_raw_f_buffered,
        expected_memory_out
    );

endtask // display_input_output_expected

module datapath_tb();
    reg          clk;
    reg          reset;

    // buffers
    reg         ir_en;
    reg         o_buff_en;

    // ALU
    reg         alu_enable;
    reg         alu_16b_mode;
    alu_op      alu_opcode;
    reg [5:0]   update_flags;

    // register file
    reg_name    reg_a_sel;
    reg_name    reg_b_sel;
    reg_name    reg_w_sel;
    reg         reg_w_en;
    reg         f_w_en;
    f_op_enum   f_op;
    exx_type    exx;
    reg[5:0]    f;

    // mux
    alu_mux_a_enum  alu_mux_a_sel;
    alu_mux_b_enum  alu_mux_b_sel;
    write_back_enum write_back_sel;

    // memory interfacing
    reg [7:0]   memory_in;
    reg [15:0]  memory_out;

    // instruction decode not tested here, ports mostly left unconnected
    mop         mop_out; // enough to make sure everything is hooked up
    // reg_name     reg_a_sel_out;
    // reg_name     reg_b_sel_out;
    // reg [7:0]    imm_0_out;
    // reg [15:0]   imm_1_out;
    // reg          use_16b_alu_out;
    // reg [5:0]    update_flags_out;
    // reg [2:0]    instruction_length_out;

    // misc
    reg [15:0]  imm_in;
    reg [2:0]   instruction_length;
    reg [5:0]   raw_f_buffered;

    reg all_pass = 1;


    typedef struct {
        reg             ir_en;
        reg             o_buff_en;
        reg             alu_enable;
        reg             alu_16b_mode;
        alu_op          alu_opcode;
        reg[5:0]        update_flags;
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

        //expected outputs
        reg[5:0]        expected_f;
        reg[5:0]        expected_raw_f_buffered;
        reg [15:0]      expected_memory_out;
    } test_vector;

    test_vector testvectors[$];

    //! Clock pulse period of 10ns
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
        .raw_f_buffered(raw_f_buffered)
    );
    /* verilator lint_on PINCONNECTEMPTY */

    task reset_tb;
        begin
            reset = 1;
            repeat(2) @(posedge clk);
            reset = 0;
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("out/sim/datapath_tb.vcd");
        $dumpvars();

        //                      ir_en, o_buff_en, alu_enable, alu_16b_mode, alu_opcode, update_flags, reg_a_sel, reg_b_sel, reg_w_sel, reg_w_en, f_w_en, f_op, exx,    alu_mux_a_sel,    alu_mux_b_sel,           write_back_sel,   memory_in, imm_in,   instuction_length, expected_f, expected_raw_f_buffered, expected_memory_out
    //  testvectors.push_back('{0,     0,         0,          0,            ALU_NOP,    6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,        B_MUX_NOP,               WB_MUX_NOP,       8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000}); // blank template
        testvectors.push_back('{0,     0,         0,          0,            ALU_NOP,    6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,        B_MUX_NOP,               WB_MUX_NOP,       8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});

        reset_tb();

      	$display("exx       | reg_a_sel | reg_b_sel | reg_w_sel | reg_w_data | reg_w_en | f_set  | f_reset | f_toggle | f_w_en | reg_a | reg_b | f      | pc");

        for (int i = 0; i < $size(testvectors); ++i) begin
            ir_en               = testvectors[i].ir_en;
            o_buff_en           = testvectors[i].o_buff_en;
            alu_enable          = testvectors[i].alu_enable;
            alu_16b_mode        = testvectors[i].alu_16b_mode;
            alu_opcode          = testvectors[i].alu_opcode;
            update_flags        = testvectors[i].update_flags;
            reg_a_sel           = testvectors[i].reg_a_sel;
            reg_b_sel           = testvectors[i].reg_b_sel;
            reg_w_sel           = testvectors[i].reg_w_sel;
            reg_w_en            = testvectors[i].reg_w_en;
            f_w_en              = testvectors[i].f_w_en;
            f_op                = testvectors[i].f_op;
            exx                 = testvectors[i].exx;
            alu_mux_a_sel       = testvectors[i].alu_mux_a_sel;
            alu_mux_b_sel       = testvectors[i].alu_mux_b_sel;
            write_back_sel      = testvectors[i].write_back_sel;
            memory_in           = testvectors[i].memory_in;
            imm_in              = testvectors[i].imm_in;
            instruction_length  = testvectors[i].instruction_length;

            #1
            display_input_output_expected_datapath(
                ir_en,
                o_buff_en,
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
                raw_f_buffered,
                memory_out, 
                testvectors[i].expected_f, 
                testvectors[i].expected_raw_f_buffered, 
                testvectors[i].expected_memory_out
            );

            if (
                testvectors[i].expected_f == f && 
                testvectors[i].expected_raw_f_buffered == raw_f_buffered &&
                testvectors[i].expected_memory_out == memory_out
            ) 
            begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL");
                all_pass = 0;
            end
            $display("");
            #9;
        end
        
        if (all_pass == 1) begin
            $display("ALL TESTS PASS");
        end else begin
            $display("FAILING TESTS!");
        end
        $finish;
    end
endmodule
