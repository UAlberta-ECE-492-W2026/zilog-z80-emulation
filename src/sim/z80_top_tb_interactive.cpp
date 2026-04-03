#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vz80_top_for_testing.h"

int trace_pc(Vz80_top_for_testing* dut, int last_pc, FILE * trace_file) {
    int current_pc;
    current_pc = (int) dut->special_reg_set[4];
    if (current_pc != last_pc) {
        fprintf(trace_file, "%04X\n", current_pc);
        last_pc = current_pc;
    }
    return last_pc;
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

    int last_pc = 0;
    int exit_pc = 268;

    // same convention as in other tbs: each clock is 10 units long
    // this is an arbitrary decision really
    vluint64_t sim_time = 0; 
    printf("Testbench Start!\n");
    while (sim_time < 25) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;
        last_pc = trace_pc(dut, last_pc,pc_trace);
    }

    dut->buttons = 0; // turn off the reset signal

    while (sim_time < 2500000) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;
        if (dut->write_char == 1) {
            printf((const char *)&dut->keyboard_char_output);
        }
        last_pc = trace_pc(dut, last_pc, pc_trace);
        if (last_pc == exit_pc) {
            break;
        }
    }

    printf("\nTestbench Exit!\n");
    m_trace->close();
    delete dut;
    return 0;
}