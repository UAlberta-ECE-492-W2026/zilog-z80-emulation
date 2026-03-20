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
        reg mem_read_buff_en,
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
        reg[5:0] raw_f,
        reg [15:0] memory_out, 

        //expected outputs
        reg[5:0] expected_f, 
        reg[5:0] expected_raw_f,
        reg [15:0] expected_memory_out
    );

//$display("ir_en|o_buff_en|mem_read_buff_en|alu_enable|alu_16b_mode|alu_opcode |update_flags|reg_a_sel|reg_b_sel|reg_w_sel|reg_w_en|f_w_en| f_op|       exx|         alu_mux_a_sel|            alu_mux_b_sel|          write_back_sel|memory_in|  imm_in|instuction_length|     f|   raw_f|memory_out");
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
//$display("ir_en|o_buff_en|mem_read_buff_en|alu_enable|alu_16b_mode|alu_opcode |update_flags|reg_a_sel|reg_b_sel|reg_w_sel|reg_w_en|f_w_en| f_op|       exx|         alu_mux_a_sel|            alu_mux_b_sel|          write_back_sel|memory_in|  imm_in|instuction_length|     f|   raw_f|memory_out");

    $write("     |         |                |          |            |           |            |         |         |         |        |      |     |          |                      |                         |                        |         |        |                 |%b| %b | %h", 
        expected_f, 
        expected_raw_f,
        expected_memory_out
    );

endtask // display_input_output_expected

module datapath_tb();
    reg          clk;
    reg          reset;

    // buffers
    reg         ir_en;
    reg         o_buff_en;
    reg         mem_read_buff_en;

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
    reg [5:0]   raw_f;

    reg all_pass = 1;


    typedef struct {
        reg             ir_en;
        reg             o_buff_en;
        reg             mem_read_buff_en;
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
        reg[5:0]        expected_raw_f;
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
            repeat(2) @(posedge clk);
            reset = 0;
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("out/sim/datapath_tb.vcd");
        $dumpvars();

        //                      ir_en, o_buff_en, mem_read_buff_en,alu_enable, alu_16b_mode, alu_opcode,     update_flags, reg_a_sel, reg_b_sel, reg_w_sel, reg_w_en, f_w_en, f_op, exx,    alu_mux_a_sel,   alu_mux_b_sel,            write_back_sel,          memory_in, imm_in,   instuction_length, expected_f, expected_raw_f, expected_memory_out
    //  testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP,        6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,       B_MUX_NOP,                WB_MUX_NOP,              8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000}); // blank template
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP,        6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,       B_MUX_NOP,                WB_MUX_NOP,              8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0037, 0,                 6'b000000,  6'b000000,               16'h0037});  // B_MUX_IMM direct
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_INSTRUCTION_LENGTH ,WB_MUX_NOP             , 8'h00,     16'h0000, 3,                 6'b000000,  6'b000000,               16'h0003});  // B_MUX_INSTRUCTION_LENGTH direct
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    A        , NONE     , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_MEMORY          , 8'h42,     16'h0001, 0,                 6'b000000,  6'b000000,               16'h0001});  // write A=0x42
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // observe A
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // turn off ALU
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_NOP       , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // other way to turn off ALU
        testvectors.push_back('{0,     1,         0,               1,          0,            ALU_PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // capture A into o_buff
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_O_BUFF    ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // observe o_buff
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    NONE     , B        , B        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_MEMORY          , 8'h18,     16'h0001, 0,                 6'b000000,  6'b000000,               16'h0001});  // write B=0x18
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // B selector setup
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    NONE     , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0018});  // observe B
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_ADD       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h005A});  // ADD A,B
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_COMPARE   , 6'b111111,    A        , B        , NONE     , 0,        1,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b001010,               16'h002A});  // COMPARE A,B, set flags
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_INC       , 6'b000000,    A        , NONE     , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_NOP                ,WB_MUX_ALU             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h0043});  // INC A
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_ADD       , 6'b000000,    A        , NONE     , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_ALU             , 8'h00,     16'h00FF, 0,                 6'b001010,  6'b001001,               16'h0042});  // DEC A, but done with an ADD because DEC is broken
        testvectors.push_back('{0,     0,         1,               1,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h34,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h0000});  // prime mem_buff=0x34 for BC
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    NONE     , NONE     , BC       , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_MEMORY_READ_BUFF, 8'h12,     16'h0000, 0,                 6'b001010,  6'b010000,               16'h0000});  // write BC=0x1234, 0x34 from buff and 0x12 from memory in
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_PASS_A    , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h1234});  // observe BC
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_PASS_A    , 6'b000000,    B        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG_SHIFTED,B_MUX_IMM               ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h1200});  // A_MUX_REG_SHIFTED with B. should be B << 8.
        testvectors.push_back('{0,     0,         1,               1,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'hFF,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h0000});  // prime mem_buff=0xFF for DE
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , DE       , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_MEMORY_READ_BUFF, 8'h00,     16'hABCD, 0,                 6'b001010,  6'b000000,               16'h0000});  // write DE=0x00FF. also make sure imm doesn't get through alu when the alu is off
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_PASS_A    , 6'b000000,    DE       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b000000,               16'h00FF});  // check DE
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b001000,               16'h1333});  // ADD BC,DE
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_SUB       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b001010,               16'h1135});  // SUB BC,DE
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_ADD       , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'hFFFF, 0,                 6'b001010,  6'b001001,               16'h1233});  // ADD BC,-1
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_ADD       , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'hFFFE, 0,                 6'b001010,  6'b001001,               16'h1232});  // ADD BC,-2
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_INSTRUCTION_LENGTH ,WB_MUX_NOP             , 8'h00,     16'h0000, 3,                 6'b001010,  6'b000000,               16'h1237});  // ADD BC,instruction_length=3
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_NOP       , 6'b000000,    A        , NONE     , B        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_MEMORY          , 8'hD7,     16'h0001, 0,                 6'b001010,  6'b000000,               16'h0000});  // write B=0xD7
        testvectors.push_back('{0,     0,         0,               1,          1,            ALU_PASS_A    , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b001010,  6'b100000,               16'hD734});  // observe BC
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    NONE     , B        , F        , 1,        0,      F_NOP,EXX_NOP,A_MUX_NOP       ,B_MUX_REG                ,WB_MUX_ALU             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h00D7});  // write flags from B
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP,        6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,       B_MUX_NOP,                WB_MUX_NOP,              8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // check f
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_PASS_B    , 6'b000000,    NONE     , NONE     , F        , 1,        0,      F_NOP,EXX_NOP,A_MUX_NOP       ,B_MUX_IMM                ,WB_MUX_ALU             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0000});  // clear f
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        1,      F_SCF,EXX_NOP,A_MUX_NOP       ,B_MUX_NOP                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // SCF flag op
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP,        6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,       B_MUX_NOP,                WB_MUX_NOP,              8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // check f
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        1,      F_CCF,EXX_NOP,A_MUX_NOP       ,B_MUX_NOP                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000001,  6'b000000,               16'h0000});  // CCF flag op
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        1,      F_CCF,EXX_NOP,A_MUX_NOP       ,B_MUX_NOP                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // CCF flag op (again)
        testvectors.push_back('{0,     0,         0,               1,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , F        , 1,        0,      F_NOP,EXX_NOP,A_MUX_NOP       ,B_MUX_IMM                ,WB_MUX_ALU             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // clear f
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP       , 6'b000000,    NONE     , NONE     , NONE     , 0,        0,      F_SCF,EXX_NOP,A_MUX_NOP       ,B_MUX_NOP                ,WB_MUX_NOP             , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // SCF flag, but flag write disabled
        testvectors.push_back('{0,     0,         0,               0,          0,            ALU_NOP,        6'b000000,    NONE,      NONE,      NONE,      0,        0,      F_NOP,EXX_NOP,A_MUX_NOP,       B_MUX_NOP,                WB_MUX_NOP,              8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // check f


        reset_tb();

        $display("");

        for (int i = 0; i < $size(testvectors); ++i) begin
            if (i == 0) begin  $display("============================================================"); $display("SECTION: BLANK TEMPLATE / SANITY CHECK"); $display("============================================================");$display("ir_en|o_buff_en|mem_read_buff_en|alu_enable|alu_16b_mode|alu_opcode |update_flags|reg_a_sel|reg_b_sel|reg_w_sel|reg_w_en|f_w_en| f_op|       exx|         alu_mux_a_sel|            alu_mux_b_sel|          write_back_sel|memory_in|  imm_in|instuction_length|     f|   raw_f|memory_out");end
            ir_en               = testvectors[i].ir_en;
            o_buff_en           = testvectors[i].o_buff_en;
            mem_read_buff_en    = testvectors[i].mem_read_buff_en;
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

            if (
                testvectors[i].expected_f == f && 
                testvectors[i].expected_raw_f == raw_f &&
                testvectors[i].expected_memory_out == memory_out
            ) 
            begin
                $display("    | PASS");
            end else begin
                $display("    | FAIL at time = %f", $realtime);
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
