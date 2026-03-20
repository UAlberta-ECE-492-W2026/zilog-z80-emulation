`timescale 1ns/1ps
`include "reg_name.sv"
`include "mux_enums.sv"

/**
 module that provides the signal output logic for the controller.
 */
module controller_output (
                          c_to_dp_intf.output_maker ctrl_intf
                          );
    /* assignments ***************/

    always_comb begin: output_block
        ctrl_intf.set_default_outputs();

        if (ctrl_intf.reset_sig) begin // output the reset output
        end
        else
          case (ctrl_intf.current_state)
            uop::reset: begin
            end
            uop::nop: begin
                ctrl_intf.reg_w_en = 0;
                ctrl_intf.alu_mux_a_sel=A_MUX_REG;
                ctrl_intf.alu_mux_b_sel =B_MUX_INSTRUCTION_LENGTH;
                ctrl_intf.set_and_enable_alu_opcode(ALU_ADD);
                ctrl_intf.alu_16b_mode = 1;
                ctrl_intf.write_back_sel = WB_MUX_ALU;
            end
            uop::fetch: begin
                ctrl_intf.ir_en = 1;
                ctrl_intf.reg_a_sel = PC;
                ctrl_intf.alu_mux_a_sel = A_MUX_REG;
                ctrl_intf.alu_opcode = ALU_PASS_A;
                ctrl_intf.alu_enable = 1;
                ctrl_intf.alu_16b_mode = 1;
                ctrl_intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                ctrl_intf.mem_r_en = 1;
            end
            uop::sp_m1: begin
                ctrl_intf.reg_a_sel = SP;
                ctrl_intf.reg_w_sel = SP;
                ctrl_intf.reg_w_en = 1;
                ctrl_intf.alu_mux_b_sel = B_MUX_IMM;
                ctrl_intf.alu_mux_a_sel = A_MUX_REG;
                ctrl_intf.alu_opcode = ALU_ADD;

                end
            uop::pc_next: begin
                ctrl_intf.reg_w_sel = PC;
                ctrl_intf.reg_w_en = 1;
                ctrl_intf.alu_mux_a_sel=A_MUX_REG;
                ctrl_intf.alu_mux_b_sel =B_MUX_INSTRUCTION_LENGTH;
                ctrl_intf.alu_opcode = ALU_ADD;
                ctrl_intf.alu_enable = 1;
                ctrl_intf.alu_16b_mode = 1;
                ctrl_intf.write_back_sel = WB_MUX_ALU;
            end
            default: begin
            end
          endcase; // case (current_state)
    end;


endmodule; // controller_next_state
