#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <fstream>
#include <sstream>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vz80_top_for_testing.h"
#include "Vz80_top_for_testing_z80_top_for_testing.h"
#include "Vz80_top_for_testing_datapath.h"
#include "Vz80_top_for_testing_register_file.h"
#include "Vz80_top_for_testing_memory_wrapper.h"
#include "Vz80_top_for_testing_program_ram.h"

#define TRACE_LENGTH 10000
#define PC_TRACE_LENGTH 100000
#define MAX_RUNTIME -1 // -1 to run until a halt is reached

void trace_pc(Vz80_top_for_testing* dut, FILE * trace_file) {
    int current_pc;
    current_pc = (int) dut->special_reg_set[4];
    if (dut->state == 3 && dut->clk == 1) { // only write the PC if a fetch was done
        fprintf(trace_file, "%04X\n", current_pc);
    }
    return;
}

void safe_char_print(const char * c) {
    if (*c < 32) {
        printf("\n"); // basically ignore control chars
    } else {
        printf(c);
    }
}

int compare_to_ticks(Vz80_top_for_testing* dut, std::string* line0, std::string* line1) {
    int pc, mpc, bc, de, hl, af, ix, iy;
    int sp, msp, bcp, dep, hlp, afp;
    int correct_pc, correct_mpc, correct_bc, correct_de, correct_hl, correct_af, correct_ix, correct_iy;
    int correct_sp, correct_msp, correct_bcp, correct_dep, correct_hlp, correct_afp;
    int mod_correct_af, mod_correct_afp;

    std::string line;

    line = * line0;

    //printf("Checking state...\n");
    //printf(line.c_str());
    //printf("\n");

    correct_pc = stoi(line.substr(3,4), 0, 16);
    correct_mpc = stoi(line.substr(14,2), 0, 16);
    correct_bc = stoi(line.substr(24,4), 0, 16);
    correct_de = stoi(line.substr(34,4), 0, 16);
    correct_hl = stoi(line.substr(44,4), 0, 16);
    correct_af = stoi(line.substr(54,4), 0, 16);
    correct_ix = stoi(line.substr(63,4), 0, 16);
    correct_iy = stoi(line.substr(72,4), 0, 16);

    mod_correct_af = correct_af & 0xFFD7; // we never set the two X flags and while this is not accurate it should be fine. 

    line = * line1;
    //printf(line.c_str());
    //printf("\n");

    correct_sp = stoi(line.substr(3,4), 0, 16);
    correct_msp = stoi(line.substr(14,4), 0, 16);
    correct_bcp = stoi(line.substr(24,4), 0, 16);
    correct_dep = stoi(line.substr(34,4), 0, 16);
    correct_hlp = stoi(line.substr(44,4), 0, 16);
    correct_afp = stoi(line.substr(54,4), 0, 16);

    mod_correct_afp = correct_afp & 0xFFD7; 

    pc = dut->z80_top_for_testing->datapath->register_file->special_reg_set[4];
    mpc = dut->z80_top_for_testing->memory_wrapper->program_ram->mem[pc];
    bc = (dut->z80_top_for_testing->datapath->register_file->main_reg_set[2] << 8) + dut->z80_top_for_testing->datapath->register_file->main_reg_set[3];
    de = (dut->z80_top_for_testing->datapath->register_file->main_reg_set[4] << 8) + dut->z80_top_for_testing->datapath->register_file->main_reg_set[5];
    hl = (dut->z80_top_for_testing->datapath->register_file->main_reg_set[6] << 8) + dut->z80_top_for_testing->datapath->register_file->main_reg_set[7];
    af = (dut->z80_top_for_testing->datapath->register_file->main_reg_set[0] << 8) + dut->z80_top_for_testing->datapath->register_file->main_reg_set[1];
    ix = dut->z80_top_for_testing->datapath->register_file->special_reg_set[1];
    iy = dut->z80_top_for_testing->datapath->register_file->special_reg_set[2];

    sp = dut->z80_top_for_testing->datapath->register_file->special_reg_set[3];
    msp = (dut->z80_top_for_testing->memory_wrapper->program_ram->mem[sp+1] << 8) + dut->z80_top_for_testing->memory_wrapper->program_ram->mem[sp];
    bcp = (dut->z80_top_for_testing->datapath->register_file->alt_reg_set[2] << 8) + dut->z80_top_for_testing->datapath->register_file->alt_reg_set[3];
    dep = (dut->z80_top_for_testing->datapath->register_file->alt_reg_set[4] << 8) + dut->z80_top_for_testing->datapath->register_file->alt_reg_set[5];
    hlp = (dut->z80_top_for_testing->datapath->register_file->alt_reg_set[6] << 8) + dut->z80_top_for_testing->datapath->register_file->alt_reg_set[7];
    afp = (dut->z80_top_for_testing->datapath->register_file->alt_reg_set[0] << 8) + dut->z80_top_for_testing->datapath->register_file->alt_reg_set[1];
    int status = 0;
    if (pc != correct_pc) {
        printf("\n### Bad PC. Saw %04x and expected %04x ###\n", pc, correct_pc);
        status = -1;
    }
    if (mpc != correct_mpc) {
        printf("\n### Bad (PC). Saw %04x and expected %04x ###\n", mpc, correct_mpc);
        status = -1;
    }
    if (bc != correct_bc) {
        printf("\n### Bad BC. Saw %04x and expected %04x ###\n", bc, correct_bc);
        status = -1;
    }
    if (de != correct_de) {
        printf("\n### Bad DE. Saw %04x and expected %04x ###\n", de, correct_de);
        status = -1;
    }
    if (hl != correct_hl) {
        printf("\n### Bad HL. Saw %04x and expected %04x ###\n", hl, correct_hl);
        status = -1;
    }
    if (af != mod_correct_af) {
        printf("\n### Bad AF. Saw %04x and expected %04x or %04x ###\n", af, correct_af, mod_correct_af);
        status = -1;
    }
    if (ix != correct_ix) {
        printf("\n### Bad IX. Saw %04x and expected %04x ###\n", ix, correct_ix);
        status = -1;
    }
    if (iy != correct_iy) {
        printf("\n### Bad IY. Saw %04x and expected %04x ###\n", iy, correct_iy);
        status = -1;
    }
    if (sp != correct_sp) {
        printf("\n### Bad SP. Saw %04x and expected %04x ###\n", sp, correct_sp);
        status = -1;
    }
    // false positives due to pushing AF onto the statck when some of the X flags are set.
    // if (msp != correct_msp) {
    //     printf("\n### Bad (SP). Saw %04x and expected %04x ###\n", msp, correct_msp);
    //     status = -1;
    // }
    if (bcp != correct_bcp) {
        printf("\n### Bad BC'. Saw %04x and expected %04x ###\n", bcp, correct_bcp);
        status = -1;
    }
    if (dep != correct_dep) {
        printf("\n### Bad DE'. Saw %04x and expected %04x ###\n", dep, correct_dep);
        status = -1;
    }
    if (hlp != correct_hlp) {
        printf("\n### Bad HL'. Saw %04x and expected %04x ###\n", hlp, correct_hlp);
        status = -1;
    }
    if (afp != mod_correct_afp) {
        printf("\n### Bad AF'. Saw %04x and expected %04x or %04x ###\n", afp, correct_afp, mod_correct_afp);
        status = -1;
    }

    return status;

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
    std::ifstream ticks("ticks.txt");

    dut->clk = 0;
    dut->buttons = 1;
    //dut->override_instruction = 0;

    int pc;
    //int exit_pc = 0x8092;
    int exit_pc = 0x0047;

    int last_idx = 0;

    int clocks = 0;

    int enable_ticks_compare = 1;

    std::string line0, line1;

    // same convention as in other tbs: each clock is 10 units long
    // this is an arbitrary decision really
    vluint64_t sim_time = 0; 
    printf("Testbench Start!\n---------------------\n");
    while (sim_time < 25) {
        dut->clk ^= 1;
        dut->eval();
        if (dut->clk) {
            clocks++;
        }
        m_trace->dump(sim_time);
        sim_time += 5;
        trace_pc(dut, pc_trace);
    }

    dut->buttons = 0; // turn off the reset signal

    while (true) {
        if (sim_time > MAX_RUNTIME && MAX_RUNTIME > 0) {
            break;
        }
        dut->clk ^= 1;
        dut->eval();
        if (dut->clk) {
            clocks++;
        }
        if (sim_time < TRACE_LENGTH) {
            m_trace->dump(sim_time);
        }
        sim_time += 5;
        if (dut->write_char == 1 && dut->clk == 0) {
            safe_char_print((const char *)&dut->keyboard_char_output);
        }
        char c;
        if (dut->read_char) {
            // printf("Bad read!");
            // break;
            std::cin.get(c);
            dut->keyboard_char_input = c;
        }
        if (sim_time < PC_TRACE_LENGTH) {
            trace_pc(dut, pc_trace);
        }

        if (dut->state == 3 && dut->clk == 1 && enable_ticks_compare) {
            line0 = line1;
            std::getline(ticks, line1);
            line0 = line1;
            std::getline(ticks, line1);

            if (line0.length() < 3 || line0.substr(0,3) != "pc="){
                line0 = line1;
                std::getline(ticks, line1);
            }
            if (line0.length() < 3 || line0.substr(0,3) != "pc="){
                line0 = line1;
                std::getline(ticks, line1);
            }
            if (line0.length() < 3 || line0.substr(0,3) != "pc="){
                line0 = line1;
                std::getline(ticks, line1);
            }
            if (line0.length() < 3 || line0.substr(0,3) != "pc="){
                line0 = line1;
                std::getline(ticks, line1);
            }
            if (line0.length() < 3 || line0.substr(0,3) != "pc="){
                line0 = line1;
                std::getline(ticks, line1);
            }
            if (line0.length() < 3 && line0.length() < 3) {
                enable_ticks_compare = 0; // end of file
                printf("\n### Found end of ticks file at clock %d: ###\n", clocks);
            } else {
                if (compare_to_ticks(dut, &line0, &line1) == -1) {
                    printf("### Exit due to incorrect behavior! ###\n");
                    printf("### PC = %04x\n", pc);
                    printf("### clocks = %d\n", clocks);
                    break;
                }
            }
        }

        if (dut->mop_out == 0x33) {
            break;
        }
    }

    printf("\n---------------------\n");
    if (sim_time > TRACE_LENGTH) {
        printf("Trace was terminated at time %d\n", TRACE_LENGTH);
    }
    if (sim_time > PC_TRACE_LENGTH) {
        printf("PC trace was terminated at time %d\n", PC_TRACE_LENGTH);
    }
    printf("Testbench Exit!\n");
    m_trace->close();
    delete dut;
    return 0;
}