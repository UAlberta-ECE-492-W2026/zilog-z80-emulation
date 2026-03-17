`timescale 1ns/1ps

module controller_next_state (
                              c_to_dp_intf.next_state_logic ctrl_intf,
                              input wire reset_sig
);
    import uop::*;

    always_comb begin: next_state_block
        ctrl_intf.set_next_state(ctrl_intf.current_state);
        if (reset_sig) ctrl_intf.set_next_state(uop::reset);
        else
          case (ctrl_intf.current_state)
            uop::fetch: begin
                case (ctrl_intf.mop_out)
                  LD_R_R: ctrl_intf.set_next_state(uop::ld_reg_a_reg_b);
                  LD_R_nn: ctrl_intf.set_next_state(uop::ld_reg_a_reg_b);
                  LD_R_mRd: ctrl_intf.set_next_state(uop::read_mrbuff_reg_b_imm_0);
                  PUSH_R: ctrl_intf.set_next_state(uop::sp_m1);

                  default: ctrl_intf.set_next_state(uop::invalid);
                endcase; // case (ctrl_intf.mop_out)

            end // case: uop::fetch
            /* invalid case handling */
            uop::invalid: ctrl_intf.set_next_state(uop::fetch);
            default: ctrl_intf.set_next_state(uop::fetch);
          endcase; // case (ctrl_intf.current_state)

    end;


endmodule; // controller_next_state
