#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vz80_top_for_testing.h"

#define TRACE_LENGTH 1000

int trace_pc(Vz80_top_for_testing* dut, FILE * trace_file) {
    int current_pc;
    current_pc = (int) dut->special_reg_set[4];
    if (dut->state == 3) { // only write the PC if a fetch was done
        fprintf(trace_file, "%04X\n", current_pc);
    }
    return current_pc;
}

int main (int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);

    Vz80_top_for_testing *dut = new Vz80_top_for_testing;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    FILE * pc_trace;
    pc_trace = fopen("pc_trace.log", "w");

    dut->clk = 0;
    dut->buttons = 1;
    dut->override_instruction = 0;

    int pc;
    int exit_pc = 268;

    // same convention as in other tbs: each clock is 10 units long
    // this is an arbitrary decision really
    vluint64_t sim_time = 0; 
    printf("Testbench Start!\n---------------------\n");
    while (sim_time < 25) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;
        trace_pc(dut, pc_trace);
    }

    dut->buttons = 0; // turn off the reset signal

    //while (sim_time < 2500000) {
    while (true) {
        dut->clk ^= 1;
        dut->eval();
        if (sim_time < TRACE_LENGTH) {
            m_trace->dump(sim_time);
        }
        sim_time += 5;
        if (dut->write_char == 1 && dut->clk == 0) {
            printf((const char *)&dut->keyboard_char_output);
        }
        pc = trace_pc(dut, pc_trace);
        if (pc == exit_pc) {
            break;
        }
    }

    printf("\n---------------------\n");
    if (sim_time > TRACE_LENGTH) {
        printf("Trace was terminated at time %d\n", TRACE_LENGTH);
    }
    printf("Testbench Exit!\n");
    m_trace->close();
    delete dut;
    return 0;
}