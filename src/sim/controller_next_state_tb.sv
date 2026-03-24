`timescale 1ns/1ps
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_next_state_tb();
    uop::uop_t expected;
    string curr_test;
    event  vector_applied;


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
        logic reset_sig;
        logic [5:0] flag;
        logic [7:0] imm_0;
        logic [15:0] imm_1;
    } test_vector;

    /**
     the constructor for the test vector
     */
    function automatic test_vector cons_test_vector(string    test_name,
                                                              uop::uop_t curr_state,
                                                              uop::uop_t expected_state,
                                                    mop mop_val,
                                                    logic     reset_sig=0,
                                                    logic[5:0] flag=6'b0,
                                                    logic[7:0] imm_0=0,
                                                    logic[15:0] imm_1=0);
        return '{test_name, curr_state, expected_state, mop_val, reset_sig,
                 flag, imm_0, imm_1};
    endfunction; // cons_test_vector


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
        testvectors = push_vector(testvectors, cons_test_vector("invalid to reset",uop::invalid, uop::reset, PUSH_R, 1));
        testvectors = push_vector(testvectors, cons_test_vector("reset to reset",uop::reset, uop::reset, ADD_R_R, 1));
        testvectors = push_vector(testvectors, cons_test_vector("LD_R_R", uop::fetch, uop::ld_reg_a_reg_b, LD_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("LD_R_R2", uop::ld_reg_a_reg_b, uop::pc_next, LD_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("LD_R_nn1", uop::fetch, uop::read_mrbuff_reg_b_imm_0, LD_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("LD_R_nn2", uop::read_mrbuff_reg_b_imm_0, uop::read16_reg_a_reg_b_imm_0, LD_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("LD_R_nn3", uop::read16_reg_a_reg_b_imm_0, uop::pc_next, LD_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::fetch, uop::sp_m1, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::sp_m1, uop::buff_addr_reg_a, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::buff_addr_reg_a, uop::write_reg_bH, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::write_reg_bH, uop::sp_m1_2, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::sp_m1_2, uop::buff_addr_reg_a_2, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::buff_addr_reg_a_2, uop::write_reg_bL, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("PUSH_R", uop::write_reg_bL, uop::pc_next, PUSH_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("POP_R", uop::fetch, uop::read_mrbuff_reg_b_imm_0, POP_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("POP_R", uop::read_mrbuff_reg_b_imm_0, uop::read16_reg_a_reg_b_imm_0, POP_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("POP_R", uop::sp_p2, uop::pc_next, POP_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("EX_DE_HL1", uop::fetch, uop::ex_de_hl, EX_DE_HL, 0));
        testvectors = push_vector(testvectors, cons_test_vector("EX_DE_HL2", uop::ex_de_hl, uop::pc_next, EX_DE_HL, 0));
        testvectors = push_vector(testvectors, cons_test_vector("ADD_R_R", uop::fetch, uop::add_reg_a_reg_b, ADD_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("ADD_R_R", uop::add_reg_a_reg_b, uop::pc_next, ADD_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("ADD_R_nn", uop::fetch, uop::add_reg_a_imm_1, ADD_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("ADD_R_nn", uop::add_reg_a_imm_1, uop::pc_next, ADD_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("SUB_R_nn", uop::fetch, uop::sub_reg_a_imm_1, SUB_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("SUB_R_nn", uop::sub_reg_a_imm_1, uop::pc_next, SUB_R_nn, 0));
        testvectors = push_vector(testvectors, cons_test_vector("OR_R_R", uop::fetch, uop::or_reg_a_reg_b, OR_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("OR_R_R", uop::or_reg_a_reg_b, uop::pc_next, OR_R_R, 0));
        testvectors = push_vector(testvectors, cons_test_vector("JP_nn", uop::fetch, uop::ld_reg_a_imm_1, JP_nn));
        testvectors = push_vector(testvectors, cons_test_vector("JP_nn", uop::ld_reg_a_imm_1, uop::fetch, JP_nn));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; NC", uop::fetch, uop::ld_reg_a_imm_1, JP_cc_nn,
                                                                .imm_0('b010), .flag(6'b00000)));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; NC", uop::ld_reg_a_imm_1, uop::fetch, JP_cc_nn,
                                                                .imm_0('b010), .flag(6'b00000)));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; NC", uop::fetch, uop::pc_next, JP_cc_nn,
                                                                .imm_0('b010), .flag(6'b00001)));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; C", uop::fetch, uop::ld_reg_a_imm_1, JP_cc_nn,
                                                                .imm_0('b011), .flag(6'b00001)));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; Z", uop::fetch, uop::ld_reg_a_imm_1, JP_cc_nn,
                                                                .imm_0('b001), .flag(6'b010001)));
        testvectors = push_vector(testvectors, cons_test_vector("JP_cc_nn; P/V", uop::fetch, uop::ld_reg_a_imm_1, JP_cc_nn,
                                                                .imm_0('b100), .flag(6'b010001)));
    end;

    initial begin
        foreach (testvectors[i]) begin
            #10;
            intf.current_state = testvectors[i].curr_state;
            intf.mop_out = testvectors[i].mop_val;
            expected = testvectors[i].expected_value;
            intf.reset = testvectors[i].reset_sig;
            intf.f = testvectors[i].flag;
            intf.imm_0_out = testvectors[i].imm_0;
            intf.imm_1_out = testvectors[i].imm_1;
            curr_test = testvectors[i].test_name;
            #1;
            ->vector_applied;

        end
        #10 $finish;
    end // initial begin

    always begin
        @vector_applied;
        display_input_output_expected(curr_test,
                                          intf.current_state,
                                          intf.next_state,
                                          expected,
                                          intf.reset,
                                          intf.next_state == expected);
    end

    c_to_dp_intf intf();

    controller_next_state dut (.ctrl_intf(intf));

endmodule
