`timescale 1ns/1ps
`include "reg_name.sv"

/**
 module that provides the signal output logic for the controller.
 */
module controller_output (
                          c_to_dp_intf.output_maker ctrl_intf
);
    import uop::*;

    reg wb_sel_reg;
    reg ir_en_reg;

    /* assignments ***************/
    assign ctrl_intf.write_back_sel = wb_sel_reg;
    assign ctrl_intf.ir_en = ir_en_reg;

    always_comb begin: output_block
        wb_sel_reg = 0;
        ir_en_reg = 0;
        ctrl_intf.reg_a_sel = NONE;
        ctrl_intf.reg_b_sel = NONE;
        ctrl_intf.reg_w_sel = NONE;
        ctrl_intf.reg_w_en = 0;
        ctrl_intf.exx_sig = EXX_NOP;

        if (reset) begin // output the reset output
        end
        else
          case (ctrl_intf.current_state)
            uop::reset: begin
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
