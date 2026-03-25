`timescale 1ns/1ps

module controller_next_state (c_to_dp_intf.next_state_logic ctrl_intf);
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

    uop::uop_t curr_state = ctrl_intf.current_state;

    /* concurrent assignment */
    assign j_cc = ctrl_intf.imm_0_out[2:0];

    always_comb begin: next_state_block
        set_next_state(curr_state);
        if (ctrl_intf.reset) set_next_state(uop::reset);
        else
          case (curr_state)
            uop::fetch: begin
                case (ctrl_intf.mop_out)
                  LD_R_R: set_next_state(uop::ld_reg_a_reg_b);
                  LD_R_nn: set_next_state(uop::ld_reg_a_reg_b);
                  LD_R_mRd: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  PUSH_R: set_next_state(uop::sp_m1);
                  POP_R: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  EX_DE_HL: set_next_state(uop::ex_de_hl);
                  ADD_R_R: set_next_state(uop::add_reg_a_reg_b);
                  ADD_R_nn: set_next_state(uop::add_reg_a_imm_1);
                  SUB_R_R: set_next_state(uop::sub_reg_a_reg_b);
                  SUB_R_nn: set_next_state(uop::sub_reg_a_imm_1);
                  SBC_R_R: set_next_state(uop::sbc_reg_a_reg_b);
                  OR_R_R: set_next_state(uop::or_reg_a_reg_b);
                  INC_mRd: set_next_state(uop::buff_addr_reg_a_imm_1);
                  NOP: set_next_state(uop::pc_next);
                  HALT: set_next_state(uop::fetch);
                  RL_R: set_next_state(uop::rl_reg_a);
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
                  JP_R: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  DJNZ_e: set_next_state(uop::dec_reg_b);
                  CALL_nn: set_next_state(uop::sp_m1);
                  RET: set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)

            end // case: uop::fetch
            uop::pc_next: set_next_state(uop::fetch);
            /* invalid case handling */
            uop::invalid: set_next_state(uop::fetch);

            /* load group */
            uop::ld_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (curr_state)
            end
            uop::ld_reg_a_imm_0: begin
                set_next_state(uop::pc_next);
            end
            uop::ld_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  JP_nn: set_next_state(uop::fetch);
                  JP_cc_nn: set_next_state(uop::fetch);
                  default: set_next_state(uop::invalid);
                endcase; // case (curr_state)
            end
            uop::ld_reg_b_imm_1: begin
                case(ctrl_intf.mop_out)
                  CALL_nn: set_next_state(uop::invalid);
                  default: set_next_state(uop::invalid);
                endcase; // case (curr_state)
            end

            uop::sp_m1: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::buff_addr_reg_a);
                  CALL_nn: set_next_state(uop::buff_addr_reg_a);
                  default: set_next_state(uop::invalid);

                endcase; // case (ctrl_intf.mop_out)
            end
            uop::sp_m1_2: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::buff_addr_reg_a_2);
                  CALL_nn: set_next_state(uop::buff_addr_reg_a_2);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::sp_p2: begin
                case(ctrl_intf.mop_out)
                  POP_R: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* buff uop */
            uop::buff_addr_reg_a: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::write_reg_bH);
                  CALL_nn: set_next_state(uop::write_imm_1H);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::buff_addr_reg_a_2: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::write_reg_bL);
                  CALL_nn: set_next_state(uop::write_imm_1L);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::buff_addr_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  INC_mRd: set_next_state(uop::read_mbuff_mrbuff);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* read uop */
            uop::read_mrbuff_reg_b_imm_0: begin
                case(ctrl_intf.mop_out)
                  LD_R_mRd: set_next_state(uop::read16_reg_a_reg_b_imm_0);
                  POP_R: set_next_state(uop::read16_reg_a_reg_b_imm_0);
                  JP_R: set_next_state(uop::read16_reg_a_reg_b_imm_0);
                  RET: set_next_state(uop::read16_reg_a_reg_b_imm_0);
                  default: set_next_state(uop::invalid);
                endcase; // case (curr_state)
            end
            uop::read16_reg_a_reg_b_imm_0: begin
                case(ctrl_intf.mop_out)
                  LD_R_mRd: set_next_state(uop::pc_next);
                  POP_R: set_next_state(uop::sp_p2);
                  JP_R: set_next_state(uop::invalid);
                  RET: set_next_state(uop::invalid);
                  default: set_next_state(uop::invalid);
                endcase; // case (curr_state)
            end
            uop::read_mbuff_mrbuff: begin
                case(ctrl_intf.mop_out)
                  INC_mRd: set_next_state(uop::write_mrbuffL_p1);
                  default: set_next_state(uop::invalid);
                endcase; // case (curr_state)
            end

            /* write uop */
            uop::write_reg_bH: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::sp_m1_2);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::write_imm_1H: begin
                case(ctrl_intf.mop_out)
                  CALL_nn: set_next_state(uop::sp_m1_2);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::write_reg_bL: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::write_imm_1L: begin
                case(ctrl_intf.mop_out)
                  CALL_nn: set_next_state(uop::ld_reg_b_imm_1);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::write_mrbuffL_p1: begin
                case(ctrl_intf.mop_out)
                  PUSH_R: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* exchange uop */
            uop::ex_de_hl: begin
                case(ctrl_intf.mop_out)
                  EX_DE_HL: set_next_state(uop::pc_next);
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* arithmetic */
            uop::add_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::add_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  JR_e: set_next_state(uop::fetch);
                  JR_cc_e: set_next_state(uop::fetch);
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::sub_reg_a_imm_1: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::sbc_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end
            uop::dec_reg_b: begin
                case(ctrl_intf.mop_out)
                  DJNZ_e: set_next_state( choose_next_jump_state(j_cc,
                                                 ctrl_intf.f,
                                                 uop::add_reg_a_imm_1,
                                                 uop::pc_next) );
                  default: set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* logical uop */
            uop::or_reg_a_reg_b: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end

            /* shift related */
            uop::rl_reg_a: begin
                case(ctrl_intf.mop_out)
                  default: set_next_state(uop::pc_next);
                endcase; // case (ctrl_intf.mop_out)
            end

            default: set_next_state(uop::fetch);
          endcase; // case (curr_state)

    end;


endmodule; // controller_next_state
