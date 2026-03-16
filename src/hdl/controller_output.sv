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
        if (reset) begin // output the reset output
        end
        else
          case (current_state)
            uop::reset: begin
            end
            default: begin
            end
          endcase; // case (current_state)
    end;


endmodule; // controller_next_state
