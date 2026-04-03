#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vz80_top_for_testing.h"

int main (int argc, char *argv[]) {
    Verilated::commandArgs(argc, argv);

    Vz80_top_for_testing *dut = new Vz80_top_for_testing;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->clk = 0;
    dut->buttons = 1;
    dut->override_instruction = 0;

    // same convention as in other tbs: each clock is 10 units long
    // this is an arbitrary decision really
    vluint64_t sim_time = 0; 
    printf("Testbench Start!\n");
    while (sim_time < 25) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time += 5;
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
    }

    printf("\nTestbench Exit!\n");
    m_trace->close();
    delete dut;
    return 0;
}