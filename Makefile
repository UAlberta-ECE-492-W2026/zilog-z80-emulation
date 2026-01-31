##
# 8 Bit ALU
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

out/sim:
	mkdir -p ./out/sim

# Make target for building and running a test bench. The rest of the name
# for the target comes from the ./src/sim directory, specifically the ALU
# test benches.
# Example:
# 	make run_alu_8_tb
run_alu_%: obj_dir/Valu_% out/sim
	./$<

clean:
	rm -rf ./obj_dir/ ./out

# end
