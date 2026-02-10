# Packet Organization

This document covers how the code in this project is being organized.

## Directory Structure

The paths listed here is relative to the root of the project.

- `.` is the root of the project. Contains configurations, readmes, scripts and task runners for the project.
- `./doc` is the directory that contains more in-depth documentation relating to this project.
- `./src` is the directory where the HDL source resides. Futher split into directories with roles.
  - `./src/enum` contains type definitions that are shared between HDL modules
  - `./src/hdl` contains the design of the hardware
  - `./src/sim` contains the testbenches for the hardware modules.
  Instantiates the hardware module from `./src/hdl` and asserts against some set of test vectors 
- `./obj_dir` is a temporary directory that holds the compiled hardware model after verilating
- `./out` is directory is not version controlled. Contains the waveform output of the simulator.
Requires a waveform viewer to view the waveform.
The recommended open sourced waveform viewer is [GTKWave](https://github.com/gtkwave/gtkwave) 
