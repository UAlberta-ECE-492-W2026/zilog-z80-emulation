# zilog-z80-emulation
FPGA emulation of the Zilog Z80

## Running Simulations

To verify the design, simulations are used. 
The simulation will execute the designed hardware models inside a runtime.
During the simulation, a set of input vectors are passed into the model and the resulting output signal is compared with some expected value.

To run a simulation, the dependencies listed [here](#simulations) must be present in the environment.

From there, run make from the root directory of the project with a valid target. A list of target is available in the [simulation make targets header](#simulation-make-targets).

### Simulation Make Targets

- `run_alu_8_tb` will execute the main function 8-bit ALU test bench
- `run_alu_16_tb` will execute the main function 16-bit ALU test bench
- `run_alu_8_status_tb` will execute the status signal test bench for the 8-bit ALU

## Dependencies

### Simulations

For simulation purposes, the required programs are `make`, `verilator`, and `gcc`.

#### Arch linux

``` sh
pacman -S make verilator gcc
```

