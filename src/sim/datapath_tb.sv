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
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM               ,WB_MUX_NOP      , 8'h00,     16'h0037, 0,                 6'b000000,  6'b000000,               16'h0037});  // B_MUX_IMM direct
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_INSTRUCTION_LENGTH,WB_MUX_NOP      , 8'h00,     16'h0000, 3,                 6'b000000,  6'b000000,               16'h0003});  // B_MUX_INSTRUCTION_LENGTH direct
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_m1                ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'hFFFF});  // B_MUX_m1 direct
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_m2                ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'hFFFE});  // B_MUX_m2 direct
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0000});  // B_MUX_0 direct
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    ZERO     , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0001});  // B_MUX_1 direct
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , NONE     , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY   , 8'h42,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0001});  // write A=0x42
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // A selector setup
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0042});  // observe A
        testvectors.push_back('{0,     1,         1,          0,            PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // capture A into o_buff
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_O_BUFF    ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // observe o_buff
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , B        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY   , 8'h18,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0001});  // write B=0x18
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // B selector setup
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0018});  // observe B
        testvectors.push_back('{0,     0,         1,          0,            ADD       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h005A});  // ADD A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // ADD A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            SUB       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h002A});  // SUB A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001010,               16'h0000});  // SUB A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            AND       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0000});  // AND A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0000});  // AND A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            OR        , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h005A});  // OR A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // OR A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            XOR       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h005A});  // XOR A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // XOR A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            COMPARE   , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h002A});  // COMPARE A,B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001010,               16'h0000});  // COMPARE A,B flags observe
        testvectors.push_back('{0,     0,         1,          0,            ADD       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM               ,WB_MUX_NOP      , 8'h00,     16'h0001, 0,                 6'b000000,  6'b010000,               16'h0043});  // ADD A,1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // ADD A,1 flags observe
        testvectors.push_back('{0,     0,         1,          0,            SUB       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_IMM               ,WB_MUX_NOP      , 8'h00,     16'h0010, 0,                 6'b000000,  6'b010000,               16'h0032});  // SUB A,0x10
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000010,               16'h0000});  // SUB A,0x10 flags observe
        testvectors.push_back('{0,     0,         1,          0,            INC       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0043});  // INC A
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // INC A flags observe
        testvectors.push_back('{0,     0,         1,          0,            DEC       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0041});  // DEC A
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000010,               16'h0000});  // DEC A flags observe
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY   , 8'h81,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0001});  // write A=0x81 for shifts
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0042});  // A selector setup after shift seed
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0081});  // observe A=0x81
        testvectors.push_back('{0,     0,         1,          0,            SLL       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0002});  // SLL A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000001,               16'h0000});  // SLL flags observe
        testvectors.push_back('{0,     0,         1,          0,            SRL       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0040});  // SRL A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000001,               16'h0000});  // SRL flags observe
        testvectors.push_back('{0,     0,         1,          0,            SLA       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0002});  // SLA A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000001,               16'h0000});  // SLA flags observe
        testvectors.push_back('{0,     0,         1,          0,            SRA       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h00C0});  // SRA A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000101,               16'h0000});  // SRA flags observe
        testvectors.push_back('{0,     0,         1,          0,            ROL       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0003});  // ROL A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000100,               16'h0000});  // ROL flags observe
        testvectors.push_back('{0,     0,         1,          0,            ROR       , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h00C0});  // ROR A by 1
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000100,               16'h0000});  // ROR flags observe
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h12,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0001});  // prime mem_buff=0x12 for BC
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    BC       , NONE     , BC       , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY_BUFF, 8'h34,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0001});  // write BC=0x1234
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h1800});  // BC selector setup
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    BC       , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h1234});  // observe BC
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    B        , NONE     , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG_SHIFTED,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h3400});  // A_MUX_REG_SHIFTED with B
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0001});  // prime mem_buff=0x00 for DE
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    BC       , DE       , DE       , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY_BUFF, 8'hFF,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0001});  // write DE=0x00FF
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h1234});  // DE selector setup
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h00FF});  // observe DE via B_MUX_REG
        testvectors.push_back('{0,     0,         1,          1,            ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001000,               16'h1333});  // ADD BC,DE
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001000,               16'h0000});  // ADD BC,DE flags observe
        testvectors.push_back('{0,     0,         1,          1,            SUB       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h1135});  // SUB BC,DE
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001010,               16'h0000});  // SUB BC,DE flags observe
        testvectors.push_back('{0,     0,         1,          1,            INC       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h1235});  // INC BC
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // INC BC flags observe
        testvectors.push_back('{0,     0,         1,          1,            DEC       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h1233});  // DEC BC
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000010,               16'h0000});  // DEC BC flags observe
        testvectors.push_back('{0,     0,         1,          1,            ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_m1                ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h1233});  // ADD BC,-1
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001001,               16'h0000});  // ADD BC,-1 flags observe
        testvectors.push_back('{0,     0,         1,          1,            ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_m2                ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h1232});  // ADD BC,-2
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b001001,               16'h0000});  // ADD BC,-2 flags observe
        testvectors.push_back('{0,     0,         1,          1,            ADD       , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_INSTRUCTION_LENGTH,WB_MUX_NOP      , 8'h00,     16'h0000, 3,                 6'b000000,  6'b010000,               16'h1237});  // ADD BC,instruction_length=3
        testvectors.push_back('{0,     0,         1,          1,            PASS_B    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // ADD BC,instruction_length=3 flags observe
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    D        , DE       , D        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_MEMORY   , 8'hAB,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h0001});  // write D=0xAB
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    D        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0000});  // D selector setup
        testvectors.push_back('{0,     1,         1,          0,            PASS_A    , 6'b000000,    D        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b010000,               16'h00AB});  // capture D into o_buff
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    D        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_O_BUFF    ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h00AB});  // observe o_buff from D
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h00AB});  // setup A before WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          0,            ADD       , 6'b000000,    A        , B        , A        , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_1                 ,WB_MUX_ALU      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0082});  // WB_MUX_ALU write A=A+1
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0081});  // A selector setup after WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , B        , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0082});  // observe updated A after WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    BC       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0082});  // setup BC/DE before 16b WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          1,            ADD       , 6'b000000,    BC       , DE       , HL       , 1,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_REG               ,WB_MUX_ALU      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'hBE33});  // WB_MUX_ALU write HL=BC+DE
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    HL       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b101000,               16'h1234});  // HL selector setup after WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          1,            PASS_A    , 6'b000000,    HL       , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'hBE33});  // observe HL after WB_MUX_ALU
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b000000,    A        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b100000,               16'h0033});  // setup A before flag write
        testvectors.push_back('{0,     0,         1,          0,            PASS_A    , 6'b111111,    A        , DE       , NONE     , 0,        1,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b000000,  6'b000000,               16'h0082});  // write flags from PASS_A(A)
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b100000,  6'b100000,               16'h0000});  // observe F after ALU flag write
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , DE       , NONE     , 0,        1,      F_SCF,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b100000,  6'b010000,               16'h0000});  // SCF flag op
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b100001,  6'b010000,               16'h0000});  // observe F after SCF
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , DE       , NONE     , 0,        1,      F_CCF,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b100001,  6'b010000,               16'h0000});  // CCF flag op
        testvectors.push_back('{0,     0,         1,          0,            PASS_B    , 6'b000000,    A        , DE       , NONE     , 0,        0,      F_NOP,EXX_NOP,A_MUX_REG       ,B_MUX_0                 ,WB_MUX_NOP      , 8'h00,     16'h0000, 0,                 6'b100000,  6'b010000,               16'h0000});  // observe F after CCF


        reset_tb();

      	$display("exx       | reg_a_sel | reg_b_sel | reg_w_sel | reg_w_data | reg_w_en | f_set  | f_reset | f_toggle | f_w_en | reg_a | reg_b | f      | pc");

        for (int i = 0; i < $size(testvectors); ++i) begin
            if (i == 0) begin $display(""); $display("============================================================"); $display("SECTION: BLANK TEMPLATE / SANITY CHECK"); $display("============================================================"); end
            if (i == 1) begin $display(""); $display("============================================================"); $display("SECTION: B_MUX CONSTANTS AND IMMEDIATE SOURCES"); $display("============================================================"); end
            if (i == 8) begin $display(""); $display("============================================================"); $display("SECTION: 8-BIT REGISTER WRITEBACK AND A/O_BUFF ROUTING"); $display("============================================================"); end
            if (i == 13) begin $display(""); $display("============================================================"); $display("SECTION: B REGISTER ROUTING"); $display("============================================================"); end
            if (i == 16) begin $display(""); $display("============================================================"); $display("SECTION: 8-BIT ALU ARITHMETIC AND LOGIC"); $display("============================================================"); end
            if (i == 36) begin $display(""); $display("============================================================"); $display("SECTION: SHIFT AND ROTATE OPERATIONS"); $display("============================================================"); end
            if (i == 51) begin $display(""); $display("============================================================"); $display("SECTION: 16-BIT REGISTER SEEDING AND ROUTING"); $display("============================================================"); end
            if (i == 60) begin $display(""); $display("============================================================"); $display("SECTION: 16-BIT ALU ARITHMETIC"); $display("============================================================"); end
            if (i == 74) begin $display(""); $display("============================================================"); $display("SECTION: O_BUFF REUSE AND WB_MUX_ALU WRITEBACK"); $display("============================================================"); end
            if (i == 86) begin $display(""); $display("============================================================"); $display("SECTION: FLAG WRITEBACK, SCF, AND CCF"); $display("============================================================"); end
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
