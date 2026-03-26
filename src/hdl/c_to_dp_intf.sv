`timescale 1ns/1ps
`include "alu_op.sv"
`include "mop.sv"
`include "exx_type.sv"
`include "reg_name.sv"
`include "f_op.sv"
`include "mux_enums.sv"

/**
Interface for the connection between the controller and the datapath.
 */
interface c_to_dp_intf();

    /* verilator lint_off UNDRIVEN */
    /* verilator lint_off UNUSEDSIGNAL */
    /* fundamental */
    logic clk;

    // buffer control
    logic ir_en;
    logic o_buff_en;
    logic mem_read_buff_en;
    logic mem_addr_buff_en;

    // ALU control
    logic alu_enable;
    logic alu_16b_mode;
    logic [5:0] update_flags;
    alu_op            alu_opcode;

    // register file
    reg_name          reg_a_sel;
    reg_name          reg_b_sel;
    reg_name          reg_w_sel;
    logic             reg_w_en;
    logic             f_w_en;
    f_op_enum         f_op;
    exx_type          exx_sig;
    logic[5:0]        f; // see the raw_f_buffered  for direct alu flag s

    // mux
    alu_mux_a_enum    alu_mux_a_sel;
    alu_mux_b_enum    alu_mux_b_sel;
    write_back_enum   write_back_sel;
    mem_mux_enum      mem_mux_sel;
    mem_data_mux_enum mem_data_mux_sel;

    // memory interfacing
    logic[7:0]        memory_in;
    logic[15:0]       memory_out; // data or address depending on uop
    logic[31:0]       instruction_in;
    logic             mem_r_en;
    logic             mem_w_en;

    // instruction decode
    // some of these have corresponding similarly named inputs from the controller
    mop              mop_out;
    reg_name         reg_a_sel_out;
    reg_name         reg_b_sel_out;
    logic[7:0]       imm_0_out;
    logic[15:0]      imm_1_out;
    logic            use_16b_alu_out;
    logic[5:0]       update_flags_out;
    logic[2:0]       instruction_length_out;

    // misc
    logic[15:0]      imm_in;
    logic[2:0]       instruction_length;
    logic [5:0]      raw_f;
    logic            reset;

    /* state information, used by the controller sub system */
    uop::uop_t current_state;
    uop::uop_t next_state;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSEDSIGNAL */

    /* verilator lint_off UNUSEDSIGNAL */
    function automatic void set_next_state(input uop::uop_t state);
        next_state = state;
    endfunction; // set_next_state
    /* verilator lint_on UNUSEDSIGNAL */

    /**
     method that denotes if the controller should latch the new mop output
     */
    function automatic logic latch_mop();
        return current_state == uop::fetch;
    endfunction; // latch_mop

    /* output logic related *************************************/

    /** function that will disable the ALU
      */
    function automatic void disable_alu();
        alu_enable = 0;
        alu_opcode = ALU_NOP;
        alu_mux_a_sel = A_MUX_NOP;
        alu_mux_b_sel = B_MUX_NOP;
    endfunction; // disable_alu

    /* verilator lint_off UNUSEDSIGNAL */
    function automatic void enable_and_set_alu_opcode(alu_op aop,
                                                      alu_mux_a_enum mux_a = A_MUX_REG,
                                                      alu_mux_b_enum mux_b = B_MUX_IMM);
        alu_enable = 1;
        alu_opcode = aop;
        alu_mux_a_sel = mux_a;
        alu_mux_b_sel = mux_b;
    endfunction; // set_alu_opcode
    /* verilator lint_on UNUSEDSIGNAL */

    function automatic void disable_reg_w();
        reg_w_en = 0;
        reg_w_sel = NONE;
    endfunction; // disable_reg_w

    /* verilator lint_off UNUSEDSIGNAL */
    function automatic void enable_and_set_reg_w(reg_name rn);
        reg_w_en = 1;
        reg_w_sel = rn;
    endfunction; // enable_and_set_write_reg

    function automatic void set_imm(logic [15:0] v);
        imm_in = v;
    endfunction; // set_imm

    function automatic void imm_1_to_imm();
        set_imm(imm_1_out);
    endfunction; // imm_1_to_imm

    function automatic void imm_0_to_imm();
        set_imm({{8{1'b0}},imm_0_out});
    endfunction; // imm_0_to_imm
    /* verilator lint_on UNUSEDSIGNAL */

    function automatic void set_default_outputs();
        write_back_sel = WB_MUX_NOP;
        ir_en = 0;
        reg_a_sel = NONE;
        reg_b_sel = NONE;
        disable_reg_w();
        exx_sig = EXX_NOP;
        disable_alu();
        o_buff_en = 0;
        alu_16b_mode = 0;
        write_back_sel = WB_MUX_NOP;
        mem_read_buff_en = 0;
        mem_addr_buff_en = 0;
        mem_mux_sel = MEM_MUX_NOP;
        mem_w_en = 0;
        mem_r_en = 0;
        imm_in = 0; // TODO: Determine if this is a safe default
        mem_data_mux_sel = MEM_DATA_MUX_NOP;
    endfunction; // set_output_default

    modport datapath (input  clk, reset,
                      // buffers
                      input  ir_en, o_buff_en,

                      // ALU
                      input  alu_enable, alu_16b_mode,
                             alu_opcode,
                             update_flags,

                      // register file
                      input  reg_a_sel,
                      input  reg_b_sel,
                      input  reg_w_sel,
                      input  reg_w_en,
                      input  f_w_en,
                      input  f_op,
                      input  exx_sig,

                      // mux
                      input  alu_mux_a_sel,
                      input  alu_mux_b_sel,
                      input  write_back_sel,

                      // memory interfacing
                      input  memory_in,
                             instruction_in,
                             imm_in,
                             instruction_length,
                             mem_read_buff_en,

                      // instruction decode
                      // some of these have corrosponding similarly named inputs from the controller
                      output f,
                      output memory_out, // data or address depending on uop
                      output mop_out,
                      output reg_a_sel_out,
                      output reg_b_sel_out,
                      output imm_0_out,
                      output imm_1_out,
                      output use_16b_alu_out,
                      output update_flags_out,
                      output instruction_length_out,
                      output raw_f);

    modport controller (
                      // buffers
                      output ir_en, o_buff_en,

                             // ALU
                             alu_enable, alu_16b_mode, alu_opcode, update_flags,

                             // register file
                             reg_a_sel, reg_b_sel, reg_w_sel, reg_w_en, f_w_en,
                             f_op, exx_sig,

                             // mux
                             alu_mux_a_sel,
                             alu_mux_b_sel,
                             write_back_sel,

                             // memory interfacing
                             memory_in,
                             instruction_in,
                             imm_in,
                             instruction_length,
                             current_state,

                      // instruction decode
                      // some of these have corrosponding similarly named inputs from the controller
                      input  f,
                      //input  memory_out, // data or address depending on uop
                      input  mop_out,
                      input  reg_a_sel_out,
                      input  reg_b_sel_out,
                      input  imm_0_out,
                      input  imm_1_out,
                      input  use_16b_alu_out,
                      input  update_flags_out,
                      input  instruction_length_out,
                      input  clk, reset,
                      input  next_state,
                      input  raw_f,
                      import latch_mop);

    modport output_maker(output ir_en, o_buff_en,
                                // ALU
                                alu_enable, alu_16b_mode, alu_opcode,
                                update_flags,

                         // register file
                         output reg_a_sel,
                                reg_b_sel,
                                reg_w_sel,
                                reg_w_en,
                                f_w_en,
                                f_op,
                                exx_sig,

                         // mux
                         output alu_mux_a_sel,
                                alu_mux_b_sel,
                                write_back_sel,
                                mem_mux_sel,
                                mem_read_buff_en,
                                mem_addr_buff_en,
                                mem_data_mux_sel,

                         // memory interfacing
                         output memory_in,
                                instruction_in,
                                imm_in,
                                instruction_length,
                                mem_r_en,
                                mem_w_en,

                         input  current_state, reset, reg_a_sel_out,
                                reg_b_sel_out, imm_0_out, imm_1_out,
                         import disable_alu,
                         import enable_and_set_alu_opcode,
                         import set_default_outputs,
                         import enable_and_set_reg_w,
                         import disable_reg_w,
                         import set_imm,
                         import imm_1_to_imm,
                         import imm_0_to_imm
                         );

    modport next_state_logic(
                             input current_state, mop_out, reset, f, raw_f,
                                   imm_0_out,
                             import set_next_state
                             );
    
    modport memory_wrapper(
        input mem_data_mux_sel, mem_mux_sel, mem_addr_buff_en, memory_out,
        output memory_in, instruction_in 
    );
endinterface; // c_to_dp_intf

/*
 Local Variables:
 eval:(add-to-list 'flycheck-verilator-include-path "../enum")
 eval:(add-to-list 'flycheck-verilator-include-path "./")
 End:
 */
