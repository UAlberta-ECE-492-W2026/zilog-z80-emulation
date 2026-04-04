`timescale 1ns/1ps

`ifndef UOP
`define UOP
package uop;
    /**
     enum for the uop (micro-operation). These represents the states that the
     controller may take, which in turn defines the output of the controller.

     This enum is primarily used by the controller next state logic and the output
     logic.
     */
    typedef enum {invalid,
                  reset,

                  nop,
                  fetch,
                  commit_fetch,

                  /* PC ops */
                  pc_m2, // 5
                  pc_m1,
                  pc_next,

                  /* sp ops */
                  sp_m1, //8
                  sp_m1_2, /* the second stack pointer reduce in seq */
                  sp_p2,

                  /* load related */
                  ld_reg_a_reg_b, //B
                  ld_reg_a_imm_0,
                  ld_reg_a_imm_1,
                  ld_reg_b_imm_1,
                
                  read_mrbuff_reg_b_imm_0_setup, //F
                  read_mrbuff_reg_b_imm_0, //10
                  read_mrbuff_reg_b_setup,
                  read_mrbuff_reg_b,
                  read_mrbuff_imm_1_setup,
                  read_mrbuff_imm_1,
                  read_mbuff_mrbuff_setup,
                  read_mbuff_mrbuff,
                  read16_reg_a_reg_b_imm_0_setup,
                  read16_reg_a_reg_b_imm_0,
                  read16_reg_a_reg_b_setup,
                  read16_reg_a_reg_b,
                  read16_reg_a_imm_1_setup,
                  read16_reg_a_imm_1,

                  /* write control */
                  write_reg_bH, //1D
                  write_reg_bH_addr_p1,
                  write_reg_bL,
                  write_mrbuffL_p1,//20
                  write_mrbuffL_m1,
                  write_imm_0,
                  write_imm_1H,
                  write_imm_1H_addr_p1,
                  write_imm_1L,
                  write_obuffL,
                  write_obuffH_addr_p1,

                  /* buffer control */
                  buff_addr_reg_a, //28
                  buff_addr_reg_a_2,
                  buff_addr_reg_a_imm_0,
                  buff_addr_reg_b_imm_0,
                  buff_addr_imm_1,

                  /* operand buffer */
                  ld_obuff_reg_a, //2D

                  /* exchange */
                  ex_de_hl, //2E
                  ex_af_afp,
                  exx, //30

                  /* arithmetic */
                  add_reg_a_reg_b, //31
                  add_reg_a_imm_1,
                  add_reg_a_mrbuff,
                  adc_reg_a_reg_b,
                  adc_reg_a_imm_1,
                  adc_reg_a_mrbuff,
                  sub_reg_a_reg_b, 
                  sub_reg_a_imm_1,
                  sub_reg_a_mrbuff,
                  sbc_reg_a_reg_b,
                  sbc_reg_a_imm_1,
                  sbc_reg_a_mrbuff,
                  and_reg_a_reg_b,
                  and_reg_a_imm_1,
                  and_reg_a_mrbuff,
                  or_reg_a_reg_b, //40
                  or_reg_a_imm_1,
                  or_reg_a_mrbuff, 
                  xor_reg_a_reg_b,
                  xor_reg_a_imm_1,
                  xor_reg_a_mrbuff,
                  cp_reg_a_reg_b,
                  cp_reg_a_imm_1,
                  cp_reg_a_mrbuff,

                  dec_reg_b, // 49

                  /* general purpose group */
                  daa, //4A
                  cpl,
                  neg,
                  ccf,
                  scf,

                  /* rotate/shift */
                  rlc_reg_a,//4F
                  rlc_mbuff_mrbuff, //50
                  rl_reg_a,
                  rl_mbuff_mrbuff,
                  rrc_reg_a,
                  rrc_mbuff_mrbuff,
                  rr_reg_a,
                  rr_mbuff_mrbuff,
                  sla_reg_a,
                  sla_mbuff_mrbuff,
                  sra_reg_a,
                  sra_mbuff_mrbuff,
                  srl_reg_a,
                  srl_mbuff_mrbuff,
                  rld,
                  rrd,

                  /* bit instruction group */
                  bit_reg_a, // 5F
                  bit_mrbuff,
                  set_reg_a,
                  set_mrbuff,
                  res_reg_a,
                  res_mrbuff
                  } uop_t;
endpackage
`endif
