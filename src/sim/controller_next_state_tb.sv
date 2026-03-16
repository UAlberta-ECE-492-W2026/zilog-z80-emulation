`timescale 1ns/1ps
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_next_state_tb();
    import uop::*;
    uop::uop_t current_state_in;
    uop::uop_t next_state_res;
    uop::uop_t expected;
    reg reset_sig;
    string curr_test;

   /* verilator lint_off UNUSEDSignal */
    /**
     Function that is responsible for displaying the result of a test.
     The pass_test reg is 1 when the test passed, and 0 when the test
     failed.
     */
    task display_input_output_expected(input string test_name,
                                       c_to_dp_intf result_interface
                                       );
        $display("test name: %s", test_name);
        $display("    current_state : %s", c_to_dp_intf.current_state.name);
    endtask // display_input_output_expected


    typedef struct {
        string test_name;
        uop::uop_t curr_state;
        uop::uop_t expected_value;
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
        testvectors = push_vector(testvectors, '{"invalid to reset",uop::invalid, uop::reset, 1});
        testvectors = push_vector(testvectors, '{"reset to reset",uop::reset, uop::reset, 1});
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

    c_to_dp_intf next_state_intf;

    controller_next_state dut (
                               .ctrl_intf(next_state_inf),
                               .reset_sig(reset_sig)
                               );

endmodule
