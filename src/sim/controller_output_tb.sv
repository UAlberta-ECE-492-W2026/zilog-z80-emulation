`timescale 1ns/1ps
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_output_tb();

    /* synchronization primitive */
    event transaction_applied;
    event test_data_ready;
    event test_finished;

    /* data declaration */
    string curr_test;

    /* verilator lint_off UNUSEDSignal */
    /**
     Function that is responsible for displaying the result of a test.
     The pass_test reg is 1 when the test passed, and 0 when the test
     failed.
     */
    task display_input_output_expected(input string test_name,
                                                    uop::uop_t current_state,
                                                );
        $display("test name: %s", test_name);
        $display("    time          : %0t", $time);
        $display("    current_state : %s", current_state.name);
    endtask; // display_input_output_expected


    typedef struct {
        string test_name;
        uop::uop_t curr_state;
    } test_vector;

    function automatic test_vector cons_test(string test_name,
                                             uop::uop_t current_state);
        return '{test_name, current_state};
    endfunction; // cons_test

    task apply_transaction(input test_vector tv);
            dut_intf.current_state = tv.curr_state;
            curr_test = tv.test_name;
            #1;
    endtask; // apply_transaction

    typedef test_vector test_vectors[$];

    test_vectors testvectors;

    initial begin: file_setup
        $dumpfile("out/sim/controller_output_tb.vcd");
        $dumpvars();
    end

    initial begin: test_definition
        testvectors.push_back(cons_test("nop", uop::nop));
        testvectors.push_back(cons_test("fetch", uop::fetch));
        testvectors.push_back(cons_test("pc_m2", uop::pc_m2));
        testvectors.push_back(cons_test("pc_m1", uop::pc_m1));
        testvectors.push_back(cons_test("sp_m1", uop::sp_m1));
        testvectors.push_back(cons_test("sp_p2", uop::sp_p2));
        testvectors.push_back(cons_test("pc_next", uop::pc_next));
        testvectors.push_back(cons_test("ld_reg_a_reg_b", uop::ld_reg_a_reg_b));

        ->test_data_ready;
    end;

    initial begin: test_applications
        wait (test_data_ready.triggered);
        foreach (testvectors[i]) begin
            #10;
            apply_transaction(testvectors[i]);
            #1
            -> transaction_applied;
        end
        -> test_finished;
        $finish;
    end // initial begin

    initial begin: test_ender
        wait (test_finished.triggered);
        $finish;
    end;

    always begin: test_printout_block
        @transaction_applied;
        display_input_output_expected(curr_test,
                                      dut_intf.current_state
                                      );
    end;

    c_to_dp_intf dut_intf();

    controller_output dut (.intf(dut_intf));

endmodule
