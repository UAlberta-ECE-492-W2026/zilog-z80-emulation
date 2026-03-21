`timescale 1ns/1ps
`include "reg_name.sv"
`include "mux_enums.sv"

/**
 module that provides the signal output logic for the controller.
 */
module controller_output (
                          c_to_dp_intf.output_maker intf
                          );
    /* assignments ***************/

    always_comb begin: output_block
        intf.set_default_outputs();

        if (intf.reset) begin // output the reset output
        end
        else
          case (intf.current_state)
            uop::reset: begin
            end
            uop::nop: begin
                intf.disable_reg_w();
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_INSTRUCTION_LENGTH));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::fetch: begin
                intf.ir_en = 1;
                intf.reg_a_sel = PC;
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                intf.mem_r_en = 1;
            end
            uop::sp_m1: begin
                intf.reg_a_sel = SP;
                intf.enable_and_set_reg_w(SP);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::pc_next: begin
                intf.enable_and_set_reg_w(PC);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_INSTRUCTION_LENGTH));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_a_imm_1: begin
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_b_imm_1: begin
                intf.enable_and_set_reg_w(intf.reg_b_sel_out);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::buff_addr_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_addr_buff_en = 1;
            end
            default: begin
            end
          endcase; // case (current_state)
    end;

endmodule; // controller_next_state
