`timescale 1ns/1ps

module controller_output (
                          output wire wb_sel,
                          input       uop::uop_t current_state,
                          input wire  reset
);
    import uop::*;

    reg wb_sel_reg;

    /* assignments ***************/
    assign wb_sel = wb_sel_reg;

    always_comb begin: output_block
        wb_sel_reg = 0;
            case (current_state)
              uop::reset_uop: begin
              end
              default: begin
              end
            endcase; // case (current_state)
    end;


endmodule; // controller_next_state
