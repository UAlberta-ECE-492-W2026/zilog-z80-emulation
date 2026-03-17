`timescale 1ns/1ps
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_next_state_tb();
    import uop::*;

    uop::uop_t expected;
    reg reset_sig;
    string curr_test;

   /* verilator lint_off UNUSEDSignal */
    /**
     Function that is responsible for displaying the result of a test.
     The pass_test reg is 1 when the test passed, and 0 when the test
     failed.
     */
    function void display_input_output_expected(input string test_name,
                                                    uop::uop_t current_state,
                                                    next_state,
                                                    expected_value,
                                       reg          reset_v,
                                       pass_test);
        $display("test name: %s : %s", test_name, pass_test ? "PASS" : "FAIL");
        $display("    time          : %0t", $time);
        $display("    current_state : %s", current_state.name);
        $display("    next_state    : %s", next_state.name);
        $display("    expected_value: %s", expected_value.name);
        $display("    reset_v: %b", reset_v);
    endfunction // display_input_output_expected


    typedef struct {
        string test_name;
        uop::uop_t curr_state;
        uop::uop_t expected_value;
        mop mop_val;
        reg reset_sig;
    } test_vector;

    typedef test_vector test_vectors[];

    test_vectors testvectors;

    initial begin: file_setup
        $dumpfile("out/sim/controller_next_state_tb.vcd");
        $dumpvars();
    end

    function automatic test_vectors push_vector (test_vectors v, test_vector test);
        test_vectors ret_array = new [v.size() + 1] (v);
        ret_array[v.size()] = test;
        return ret_array;
    endfunction // push_vector

    initial begin: test_definition
        testvectors = new [0];
        testvectors = push_vector(testvectors, '{"invalid to reset",uop::invalid, uop::reset, PUSH_R, 1});
        testvectors = push_vector(testvectors, '{"reset to reset",uop::reset, uop::reset, ADD_R_R, 1});
        testvectors = push_vector(testvectors, '{"LD_R_R", uop::fetch, uop::ld_reg_a_reg_b, LD_R_R, 0});
        testvectors = push_vector(testvectors, '{"LD_R_R2", uop::ld_reg_a_reg_b, uop::pc_next, LD_R_R, 0});
        testvectors = push_vector(testvectors, '{"LD_R_nn1", uop::fetch, uop::read_mrbuff_reg_b_imm_0, LD_R_nn, 0});
        testvectors = push_vector(testvectors, '{"LD_R_nn2", uop::read_mrbuff_reg_b_imm_0, uop::read16_reg_a_reg_b_imm_0, LD_R_nn, 0});
        testvectors = push_vector(testvectors, '{"LD_R_nn3", uop::read16_reg_a_reg_b_imm_0, uop::pc_next, LD_R_nn, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::fetch, uop::sp_m1, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::sp_m1, uop::buff_addr_reg_a, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::buff_addr_reg_a, uop::write_reg_bH, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::write_reg_bH, uop::sp_m1_2, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::sp_m1_2, uop::buff_addr_reg_a_2, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::buff_addr_reg_a_2, uop::write_reg_bL, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"PUSH_R", uop::write_reg_bL, uop::pc_next, PUSH_R, 0});
        testvectors = push_vector(testvectors, '{"POP_R", uop::fetch, uop::read_mrbuff_reg_b_imm_0, POP_R, 0});
        testvectors = push_vector(testvectors, '{"POP_R", uop::read_mrbuff_reg_b_imm_0, uop::read16_reg_a_reg_b_imm_0, POP_R, 0});
        testvectors = push_vector(testvectors, '{"POP_R", uop::sp_p2, uop::pc_next, POP_R, 0});
    end;

    initial begin
        for (int i = 0; i < testvectors.size(); ++i) begin
            #10;
            next_state_intf.current_state = testvectors[i].curr_state;
            next_state_intf.mop_out = testvectors[i].mop_val;
            expected = testvectors[i].expected_value;
            reset_sig = testvectors[i].reset_sig;
            curr_test = testvectors[i].test_name;
            #1;
        end
        #10 $finish;
    end // initial begin

    always begin
        #11 display_input_output_expected(curr_test,
                                          next_state_intf.current_state,
                                          next_state_intf.next_state,
                                          expected,
                                          reset_sig,
                                          next_state_intf.next_state == expected);
    end

    c_to_dp_intf next_state_intf();

    controller_next_state dut (
                               .ctrl_intf(next_state_intf),
                               .reset_sig(reset_sig)
                               );

endmodule
