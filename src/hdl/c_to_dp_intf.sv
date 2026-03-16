`timescale 1ns/1ps
`include "alu_op.sv"
`include "mop.sv"
`include "exx_type.sv"
`include "reg_name.sv"

/**
Interface for the connection between the controller and the datapath.
 */
interface c_to_dp_intf();
    import uop::*;

    // buffers
    wire              ir_en;
    wire              o_buff_en;

    // ALU
    wire              alu_enable;
    wire              alu_16b_mode;
    alu_op            alu_opcode;
    wire [5:0]        update_flags;

    // register file
    reg_name          reg_a_sel;
    reg_name          reg_b_sel;
    reg_name          reg_w_sel;
    wire              reg_w_en;
    wire              f_w_en;
    f_op_enum         f_op;
    exx_type          exx;
    wire[5:0]        f; // see the raw_f_buffered  for direct alu flag s

    // mux
    alu_mux_a_enum    alu_mux_a_sel;
    alu_mux_b_enum    alu_mux_b_sel;
    write_back_enum   write_back_sel;

    // memory interfacing
    wire [7:0]        memory_in;
    wire [15:0]       memory_out; // data or address depending on uop
    wire [31:0]       instruction_in;

    // instruction decode
    // some of these have corresponding similarly named inputs from the controller
    mop              mop_out;
    reg_name         reg_a_sel_out;
    reg_name         reg_b_sel_out;
    wire [7:0]       imm_0_out;
    wire [15:0]      imm_1_out;
    wire             use_16b_alu_out;
    wire [5:0]       update_flags_out;
    wire [2:0]       instruction_length_out;

    // misc
    wire [15:0]      imm_in;
    wire [2:0]       instruction_length;
    wire [5:0]       raw_f_buffered;

    uop::uop_t current_state;
    uop::uop_t next_state;

    modport datapath (
                      // buffers
                      input  ir_en, o_buff_en,

                      // ALU
                      input  alu_enable,
                      input  alu_16b_mode,
                      input  alu_opcode,
                      input  update_flags,

                      // register file
                      input  reg_a_sel,
                      input  reg_b_sel,
                      input  reg_w_sel,
                      input  reg_w_en,
                      input  f_w_en,
                      input  f_op,
                      input  exx,

                      // mux
                      input  alu_mux_a_sel,
                      input  alu_mux_b_sel,
                      input  write_back_sel,

                      // memory interfacing
                      input  memory_in,
                      input  instruction_in,
                      input  imm_in,
                      input  instruction_length,

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
                      output raw_f_buffered);

    modport controller (
                      // buffers
                      output ir_en, o_buff_en,

                      // ALU
                      output alu_enable,
                      output alu_16b_mode,
                      output alu_opcode,
                      output update_flags,

                      // register file
                      output reg_a_sel,
                      output reg_b_sel,
                      output reg_w_sel,
                      output reg_w_en,
                      output f_w_en,
                      output f_op,
                      output exx,

                      // mux
                      output alu_mux_a_sel,
                      output alu_mux_b_sel,
                      output write_back_sel,

                      // memory interfacing
                      output memory_in,
                      output instruction_in,
                      output imm_in,
                      output instruction_length,

                      // instruction decode
                      // some of these have corrosponding similarly named inputs from the controller
                      input  f,
                      input  memory_out, // data or address depending on uop
                      input  mop_out,
                      input  reg_a_sel_out,
                      input  reg_b_sel_out,
                      input  imm_0_out,
                      input  imm_1_out,
                      input  use_16b_alu_out,
                      input  update_flags_out,
                      input  instruction_length_out,
                      input  raw_f_buffered);

    modport controller_to_output_maker(
                                       // buffers
                                       output ir_en, o_buff_en,

                                       // ALU
                                       output alu_enable, alu_16b_mode, alu_opcode,
                                              update_flags,

                                       // register file
                                       output reg_a_sel,
                                              reg_b_sel,
                                              reg_w_sel,
                                              reg_w_en,
                                              f_w_en,
                                              f_op,
                                              exx,

                                       // mux
                                       output alu_mux_a_sel,
                                              alu_mux_b_sel,
                                              write_back_sel,

                                       // memory interfacing
                                       output memory_in,
                                              instruction_in,
                                              imm_in,
                                              instruction_length,
                                       input  current_state
                                       );
    modport output_maker(
                                       // buffers
                                       input ir_en, o_buff_en,

                                       // ALU
                                       input alu_enable, alu_16b_mode, alu_opcode,
                                              update_flags,

                                       // register file
                                       input reg_a_sel,
                                              reg_b_sel,
                                              reg_w_sel,
                                              reg_w_en,
                                              f_w_en,
                                              f_op,
                                              exx,

                                       // mux
                                       input alu_mux_a_sel,
                                              alu_mux_b_sel,
                                              write_back_sel,

                                       // memory interfacing
                                       input memory_in,
                                              instruction_in,
                                              imm_in,
                                              instruction_length,
                                       output  current_state
);

    modport next_state_logic(
                             output next_state,
                             input  current_state
                             );


endinterface; // c_to_dp_intf
