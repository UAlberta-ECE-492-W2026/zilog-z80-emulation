`timescale 1ns/1ps

module controller_output (
                          output wire wb_sel,
                                      ir_en,
                                      reg_a_sel,
                                      reg_w_sel,
                                      reg_b_sel,
                          input       uop::uop_t current_state,
                          wire        reset
);
    import uop::*;

    reg wb_sel_reg;
    reg ir_en_reg;

    /* assignments ***************/
    assign wb_sel = wb_sel_reg;
    assign ir_en = ir_en_reg;

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
