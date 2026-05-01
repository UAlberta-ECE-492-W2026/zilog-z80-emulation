##
# 8/16 Bit ALU
#
# @file
# @version 0.2


.PHONY: clean


# The make target for the ALU test benches. The stem matching is done for the
# rest of the ALU testbench names.
# Example:
# 	make obj_dir/Valu_8_tb
obj_dir/Valu_%: ./src/hdl/alu_status.sv ./src/hdl/alu.sv ./src/sim/alu_%.sv ./src/enum/alu_op.sv
	verilator --binary -j 0 -Wall -cc $^ --top-module alu_$* --timing +incdir+./src/enum

obj_dir/Vcontroller: ./src/hdl/controller.sv ./src/enum/uop.sv ./src/enum/reg_name.sv
	verilator --binary -j 0 -Wall -cc $^ --top-module controller --timing +incdir+./src/enum

out/sim:
	mkdir -p ./out/sim

# Make target for building and running a test bench. The rest of the name
# for the target comes from the ./src/sim directory, specifically the ALU
# test benches.
# Example:
# 	make run_alu_8_tb
run_alu_%: obj_dir/Valu_% out/sim
	./$<

# this makefile is called if you do a 'make clean' so it is a superset of all other make clean targets here.
# this is terrible makefile design, but it does work i guess
clean:
	rm -rf ./obj_dir/ ./out
	rm -f pc_trace.log
	rm -f ticks.txt
	rm -f .stamp*

# end
