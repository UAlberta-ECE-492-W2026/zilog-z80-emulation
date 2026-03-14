`timescale 1ns/1ps
`include "uop.sv"

module controller_output (
                          output wire wb_sel,
                          input       uop current_state
);

    reg wb_sel_reg;

    /* assignments ***************/
    assign wb_sel = wb_sel_reg;

    always_comb begin: output_block
        wb_sel_reg = 0;
        if (reset) aluop_reg = 0;
        else begin
            case (current_state)
              reset_uop: begin
              end
              default: begin
              end
            endcase; // case (current_state)
        end;
    end;


endmodule; // controller_next_state
