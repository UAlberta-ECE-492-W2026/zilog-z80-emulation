`timescale 1ns/1ps

module controller_next_state (c_to_dp_intf.controller_next_state ctrl_intf);
    wire logic[2:0] j_cc;

    /* verilator lint_off UNUSEDSIGNAL */
    function automatic void set_next_state(input uop::uop_t next_state);
        ctrl_intf.set_next_state(next_state);
    endfunction; // set_next_state
    /* verilator lint_on UNUSEDSIGNAL */


    /* verilator lint_off UNUSEDSIGNAL */
    /* jump helper functions */
    function automatic logic jump_flag_lookup(logic[2:0] jump_cc, logic[5:0] flag);
        if (jump_cc == 3'b000 || jump_cc == 3'b001) begin /* zero flag stuff */
            return flag[4];
        end else if (jump_cc == 3'b010 || jump_cc == 3'b011 ) begin /* carry flag */
            return flag[0];
        end else if (jump_cc == 3'b100 || jump_cc == 3'b101) begin /* parity/overflow */
            return flag[2];
        end else if (jump_cc == 3'b110 || jump_cc == 3'b111) begin /* sign flag */
            return flag[5];
        end else begin
            return 0;
        end
    endfunction; // jump_flag_lookup

    function automatic logic jump_conditional_value_processing(logic [2:0] jump_cc,
                                                               logic      flag_val);
        return jump_cc[0] ~^ flag_val;
    endfunction; // jump_conditional_value_processing

    function automatic logic jump_conditional(logic [2:0] jump_cc,
                                              logic [5:0] flag );
        return jump_conditional_value_processing(jump_cc,
                                          jump_flag_lookup(jump_cc,
                                                           flag));
    endfunction; // jump_conditional

    function automatic uop::uop_t choose_next_jump_state(logic [2:0] jump_cc,
                                                         logic [5:0] flag,
                                                         uop::uop_t triggered_state,
                                                         uop::uop_t missed_state=uop::pc_next);
        if (jump_conditional(jump_cc, flag))
          return triggered_state;
        else
          return missed_state;
    endfunction; // choose_next_jump_state

    /* verilator lint_on UNUSEDSIGNAL */

    /* concurrent assignment */
    assign j_cc = ctrl_intf.imm_0_out[2:0];

    always_comb begin: next_state_block
        set_next_state(ctrl_intf.current_state);
        if (ctrl_intf.reset) set_next_state(uop::reset);
        else
          case (ctrl_intf.current_state)
            uop::fetch: begin
              set_next_state(uop::commit_fetch);
            end
            uop::commit_fetch: begin
                case (ctrl_intf.mop_out)
                  LD_R_R: set_next_state(uop::ld_reg_a_reg_b);
                  LD_R_nn: set_next_state(uop::ld_reg_a_imm_1);
                  LD_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  LD_mRd_R, LD_mRd_n: set_next_state(uop::buff_addr_reg_a_imm_1);
                  LD_R_mnn: set_next_state(uop::read_mrbuff_imm_1);
                  LD_mnn_A, LD_mnn_R: set_next_state(uop::buff_addr_imm_1);
                  PUSH_R: set_next_state(uop::sp_m1);
                  POP_R: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  EX_DE_HL: set_next_state(uop::ex_de_hl);
                  EX_AF_AFp: set_next_state(uop::ex_af_afp);
                  EXX: set_next_state(uop::exx);
                  EX_mR_R: set_next_state(uop::ld_obuff_reg_a);
                  ADD_R_R: set_next_state(uop::add_reg_a_reg_b);
                  ADD_R_nn: set_next_state(uop::add_reg_a_imm_1);
                  ADD_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  ADC_R_R: set_next_state(uop::adc_reg_a_reg_b);
                  ADC_R_nn: set_next_state(uop::adc_reg_a_imm_1);
                  ADC_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  SUB_R_R: set_next_state(uop::sub_reg_a_reg_b);
                  SUB_R_nn: set_next_state(uop::sub_reg_a_imm_1);
                  SUB_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  SBC_R_R: set_next_state(uop::sbc_reg_a_reg_b);
                  SBC_R_nn: set_next_state(uop::sbc_reg_a_imm_1);
                  SBC_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  AND_R_R: set_next_state(uop::and_reg_a_reg_b);
                  AND_R_nn: set_next_state(uop::and_reg_a_imm_1);
                  AND_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  OR_R_R: set_next_state(uop::or_reg_a_reg_b);
                  OR_R_nn: set_next_state(uop::or_reg_a_imm_1);
                  OR_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  XOR_R_R: set_next_state(uop::xor_reg_a_reg_b);
                  XOR_R_nn: set_next_state(uop::xor_reg_a_imm_1);
                  XOR_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  CP_R_R: set_next_state(uop::cp_reg_a_reg_b);
                  CP_R_nn: set_next_state(uop::cp_reg_a_imm_1);
                  CP_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  INC_mRd, DEC_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  DAA: set_next_state(uop::daa);
                  CPL: set_next_state(uop::cpl);
                  NEG: set_next_state(uop::neg);
                  CCF: set_next_state(uop::ccf);
                  SCF: set_next_state(uop::scf);
                  NOP: set_next_state(uop::pc_next);
                  HALT: set_next_state(uop::fetch);
                  RLC_R: set_next_state(uop::rlc_reg_a);
                  RLC_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  RL_R: set_next_state(uop::rl_reg_a);
                  RL_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  RRC_R: set_next_state(uop::rrc_reg_a);
                  RRC_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  RR_R: set_next_state(uop::rr_reg_a);
                  RR_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  SLA_R: set_next_state(uop::sla_reg_a);
                  SLA_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  SRA_R: set_next_state(uop::sra_reg_a);
                  SRA_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  SRL_R: set_next_state(uop::srl_reg_a);
                  SRL_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  RLD, RRD: set_next_state(uop::buff_addr_reg_a);
                  JP_nn: set_next_state(uop::ld_reg_a_imm_1);
                  JP_cc_nn: set_next_state(choose_next_jump_state(j_cc,
                                                                  ctrl_intf.f,
                                                                  uop::ld_reg_a_imm_1,
                                                                  uop::pc_next));
                  JR_e: set_next_state(uop::add_reg_a_imm_1);
                  JR_cc_e: set_next_state( choose_next_jump_state(j_cc,
                                                  ctrl_intf.f,
                                                  uop::add_reg_a_imm_1,
                                                  uop::pc_next) );
                  JP_R: set_next_state(uop::ld_reg_a_reg_b);
                  DJNZ_e: set_next_state(uop::dec_reg_b);
                  CALL_cc_nn,
                  CALL_nn: set_next_state(uop::pc_next);
                  RET: set_next_state(uop::read_mrbuff_reg_b);
                  RET_cc: set_next_state(choose_next_jump_state(j_cc,
                                                                ctrl_intf.f,
                                                                uop::read_mrbuff_reg_b,
                                                                uop::pc_next));

                  default: set_next_state(uop::invalid);
                endcase;

            end // case: uop::fetch
            uop::pc_next: case(ctrl_intf.mop_out)
                            CALL_nn: set_next_state(uop::sp_m1);
                            CALL_cc_nn: set_next_state(choose_next_jump_state(j_cc,
                                                                              ctrl_intf.f,
                                                                              uop::sp_m1,
                                                                              uop::fetch));

                            default: set_next_state(uop::fetch);
                          endcase

            /* invalid case handling */
            uop::invalid: set_next_state(uop::fetch);

            /* load group */
            uop::ld_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  JP_R: set_next_state(uop::fetch);
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::ld_reg_a_imm_0: begin
                set_next_state(uop::pc_next);
            end
            uop::ld_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  JP_nn, JP_cc_nn: set_next_state(uop::fetch);
                  LD_R_nn: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::ld_reg_b_imm_1: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn: set_next_state(uop::fetch);
                  default: set_next_state(uop::invalid);
                endcase;
            end

            uop::sp_m1: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn,
                  PUSH_R: set_next_state(uop::buff_addr_reg_a);
                  default: set_next_state(uop::invalid);

                endcase;
            end
            uop::sp_m1_2: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn,
                  PUSH_R: set_next_state(uop::buff_addr_reg_a_2);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::sp_p2: begin
                case(ctrl_intf.mop_out)
                  RET_cc,
                  RET: set_next_state(uop::fetch);
                  POP_R: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end

            /* buff uop */
            uop::buff_addr_reg_a: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn,
                  PUSH_R: set_next_state(uop::write_reg_bH);
                  RLD,
                  RRD: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::buff_addr_reg_a_2: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn,
                  PUSH_R: set_next_state(uop::write_reg_bL);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::buff_addr_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  INC_mRd, DEC_mRd: set_next_state(uop::read_mbuff_mrbuff);
                  LD_mRd_R: set_next_state(uop::write_reg_bL);
                  LD_mRd_n: set_next_state(uop::write_imm_1L);
                  RLC_mRd,
                  RL_mRd,
                  RRC_mRd,
                  RR_mRd,
                  SLA_mRd,
                  SRA_mRd,
                  SRL_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::buff_addr_reg_b_imm_1: begin
                case(ctrl_intf.mop_out)
                  EX_mR_R: set_next_state(uop::write_obuffL);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::buff_addr_imm_1: begin
              case(ctrl_intf.mop_out)
                LD_mnn_A, LD_mnn_R: set_next_state(uop::write_reg_bL);
                default: set_next_state(uop::invalid);
              endcase
            end

            /* operand buffer */
            uop::ld_obuff_reg_a: begin
              case(ctrl_intf.mop_out)
                EX_mR_R: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                default: set_next_state(uop::invalid);
              endcase
            end

            /* read uop */
            uop::read_mrbuff_reg_b: begin
                case(ctrl_intf.mop_out)
                  RET_cc, RET: set_next_state(uop::read16_reg_a_reg_b);
                  default: set_next_state(uop::invalid);
                endcase;
            end

            uop::read_mrbuff_reg_b_imm_0: begin
                case(ctrl_intf.mop_out)
                  LD_R_mRd, EX_mR_R, POP_R: set_next_state(uop::read16_reg_a_reg_b_imm_0);
                  ADD_R_mRd: set_next_state(uop::add_reg_a_mrbuff);
                  ADC_R_mRd: set_next_state(uop::adc_reg_a_mrbuff);
                  SUB_R_mRd: set_next_state(uop::sub_reg_a_mrbuff);
                  SBC_R_mRd: set_next_state(uop::sbc_reg_a_mrbuff);
                  AND_R_mRd: set_next_state(uop::and_reg_a_mrbuff);
                  OR_R_mRd: set_next_state(uop::or_reg_a_mrbuff);
                  XOR_R_mRd: set_next_state(uop::xor_reg_a_mrbuff);
                  CP_R_mRd: set_next_state(uop::cp_reg_a_mrbuff);
                  RLC_mRd: set_next_state(uop::rlc_mbuff_mrbuff);
                  RL_mRd: set_next_state(uop::rl_mbuff_mrbuff);
                  RRC_mRd: set_next_state(uop::rrc_mbuff_mrbuff);
                  RR_mRd: set_next_state(uop::rr_mbuff_mrbuff);
                  SLA_mRd: set_next_state(uop::sla_mbuff_mrbuff);
                  SRA_mRd: set_next_state(uop::sra_mbuff_mrbuff);
                  SRL_mRd: set_next_state(uop::srl_mbuff_mrbuff);
                  RLD: set_next_state(uop::rld);
                  RRD: set_next_state(uop::rrd);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::read_mrbuff_imm_1: begin
              case(ctrl_intf.mop_out)
                LD_R_mnn: set_next_state(uop::read16_reg_a_imm_1);
                default: set_next_state(uop::invalid);
              endcase
            end
            uop::read16_reg_a_reg_b: case(ctrl_intf.mop_out)
                                       RET, RET_cc: set_next_state(uop::sp_p2);
                                       default: set_next_state(uop::invalid);
                                     endcase
            uop::read16_reg_a_reg_b_imm_0: begin
                case(ctrl_intf.mop_out)
                  LD_R_mRd: set_next_state(uop::pc_next);
                  POP_R: set_next_state(uop::sp_p2);
                  EX_mR_R: set_next_state(uop::buff_addr_reg_b_imm_1);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::read16_reg_a_imm_1: begin
              case(ctrl_intf.mop_out)
                LD_R_mnn: set_next_state(uop::pc_next);
                default: set_next_state(uop::invalid);
              endcase
            end
            uop::read_mbuff_mrbuff: begin
                case(ctrl_intf.mop_out)
                  INC_mRd: set_next_state(uop::write_mrbuffL_p1);
                  DEC_mRd: set_next_state(uop::write_mrbuffL_m1);
                  default: set_next_state(uop::invalid);
                endcase;
            end

            /* write uop */
            uop::write_reg_bH: begin
                case(ctrl_intf.mop_out)
                  CALL_cc_nn,
                  CALL_nn,
                  PUSH_R: set_next_state(uop::sp_m1_2);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_reg_bH_addr_p1: begin
                case(ctrl_intf.mop_out)
                  LD_mnn_R: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_imm_1H: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_reg_bL: begin
                case(ctrl_intf.mop_out)
                  PUSH_R, LD_mRd_R, LD_mnn_A: set_next_state(uop::pc_next);
                  LD_mnn_R: set_next_state(uop::write_reg_bH_addr_p1);
                  CALL_cc_nn,
                  CALL_nn: set_next_state(uop::ld_reg_b_imm_1);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_imm_1L: begin
                case(ctrl_intf.mop_out)
                  LD_mRd_n: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_obuffL: begin
              case(ctrl_intf.mop_out)
                EX_mR_R: set_next_state(uop::write_obuffH_addr_p1);
                default: set_next_state(uop::invalid);
              endcase
            end
            uop::write_obuffH_addr_p1: begin
              case(ctrl_intf.mop_out)
                EX_mR_R: set_next_state(uop::pc_next);
                default: set_next_state(uop::invalid);
              endcase
            end
            uop::write_mrbuffL_p1: begin
                case(ctrl_intf.mop_out)
                  PUSH_R, INC_mRd: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::write_mrbuffL_m1: begin
                case(ctrl_intf.mop_out)
                  DEC_mRd: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase;
            end

            /* exchange uop */
            uop::ex_de_hl, uop::ex_af_afp, uop::exx: begin
              set_next_state(uop::pc_next);
            end

            /* General purpose group*/
            uop::ccf, uop::scf: begin
              set_next_state(uop::pc_next);
            end

            /* arithmetic */
            uop::add_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::add_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  JR_e, JR_cc_e, DJNZ_e: set_next_state(uop::fetch);
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::adc_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::adc_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::sub_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::sub_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::sbc_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::sbc_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::and_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::and_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::or_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::or_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::xor_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::xor_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::cp_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::cp_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase;
            end
            uop::dec_reg_b: begin
                case(ctrl_intf.mop_out)
                  DJNZ_e: set_next_state( choose_next_jump_state(j_cc,
                                                 ctrl_intf.raw_f,
                                                 uop::add_reg_a_imm_1,
                                                 uop::pc_next) );
                  default: set_next_state(uop::invalid);
                endcase;
            end
            uop::add_reg_a_mrbuff,
            uop::adc_reg_a_mrbuff,
            uop::sub_reg_a_mrbuff,
            uop::sbc_reg_a_mrbuff,
            uop::and_reg_a_mrbuff,
            uop::or_reg_a_mrbuff,
            uop::xor_reg_a_mrbuff,
            uop::cp_reg_a_mrbuff:
            begin
              set_next_state(uop::pc_next);
            end
            uop::daa,
            uop::cpl,
            uop::neg: begin
              set_next_state(uop::pc_next);
            end

            /* rotate/shift related */
            uop::rlc_reg_a,
            uop::rlc_mbuff_mrbuff,
            uop::rl_reg_a,
            uop::rl_mbuff_mrbuff,
            uop::rrc_reg_a,
            uop::rrc_mbuff_mrbuff,
            uop::rr_reg_a,
            uop::rr_mbuff_mrbuff,
            uop::sla_reg_a,
            uop::sla_mbuff_mrbuff,
            uop::sra_reg_a,
            uop::sra_mbuff_mrbuff,
            uop::srl_reg_a,
            uop::srl_mbuff_mrbuff,
            uop::rld,
            uop::rrd: begin
              set_next_state(uop::pc_next);
            end

            default: set_next_state(uop::fetch);
          endcase;

    end;


endmodule // controller_next_state
