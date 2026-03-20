`timescale 1ns/1ps
`include "mop.sv"

/* verilator lint_on UNUSEDSignal */
module controller_output_tb();
    string curr_test;

   /* verilator lint_off UNUSEDSignal */
    /**
     Function that is responsible for displaying the result of a test.
     The pass_test reg is 1 when the test passed, and 0 when the test
     failed.
     */
    function void display_input_output_expected(input string test_name,
                                                    uop::uop_t current_state,
                                                );
        $display("test name: %s", test_name);
        $display("    time          : %0t", $time);
        $display("    current_state : %s", current_state.name);
    endfunction // display_input_output_expected


    typedef struct {
        string test_name;
        uop::uop_t curr_state;
    } test_vector;

    function automatic test_vector cons_test(string test_name,
                                             uop::uop_t current_state);
        return '{test_name, current_state};
    endfunction; // cons_test

    task apply_transaction(input test_vector tv);
            #10;
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
    end;

    initial begin
        foreach (testvectors[i]) begin
            apply_transaction(testvectors[i]);
        end
        #10 $finish;
    end // initial begin

    always begin
        #11 display_input_output_expected(curr_test,
                                          dut_intf.current_state
                                          );
    end

    c_to_dp_intf dut_intf();

    controller_output dut (.ctrl_intf(dut_intf));

endmodule
