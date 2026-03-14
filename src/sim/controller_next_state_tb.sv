`timescale 1ns/1ps
`include "uop.sv"
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_next_state_tb();
    uop current_state_in;
    uop next_state_res;
    uop expected;
    reg reset_sig;
    string curr_test;

   /* verilator lint_off UNUSEDSignal */
    /**
     Function that is responsible for displaying the result of a test.
     The pass_test reg is 1 when the test passed, and 0 when the test
     failed.
     */
    task display_input_output_expected(input string test_name,
                                       uop current_state,
                                                    next_state,
                                                    expected_value,
                                       reg          reset_v,
                                                    pass_test);
        $display("test name: %s : %s", test_name, pass_test ? "PASS" : "FAIL");
        $display("    current_state : %s", current_state.name);
        $display("    next_state    : %s", next_state.name);
        $display("    expected_value: %s", expected_value.name);
        $display("    reset_v: %b", reset_v);
    endtask // display_input_output_expected


    typedef struct {
        string test_name;
        uop curr_state;
        uop expected_value;
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
        testvectors = push_vector(testvectors, '{"invalid to reset",invalid_uop, reset_uop, 1});
        testvectors = push_vector(testvectors, '{"reset to reset",reset_uop, reset_uop, 1});
    end;

    initial begin
        for (int i = 0; i < testvectors.size(); ++i) begin
            #10;
            current_state_in = testvectors[i].curr_state;
            expected = testvectors[i].expected_value;
            reset_sig = testvectors[i].reset_sig;
            curr_test = testvectors[i].test_name;
            #1;
        end
        #10 $finish;
    end // initial begin

    always begin
        #11 display_input_output_expected(curr_test,
                                          current_state_in,
                                          next_state_res,
                                          expected,
                                          reset_sig,
                                          next_state_res == expected);
    end

    controller_next_state dut (
                               .next_state(next_state_res),
                               .current_state(current_state_in),
                               .reset_sig(reset_sig)
                               );

endmodule
