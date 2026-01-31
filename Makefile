##
# 8 Bit ALU
#
# @file
# @version 0.1


.PHONY: clean

run_alu_8_tb: obj_dir/Valu_8_tb out/sim
	./$<

# The make target for the ALU test benches. The stem matching is done for the
# rest of the ALU testbench names.
# Example:
# 	obj_dir/Valu_8_tb
obj_dir/Valu_%: ./src/hdl/alu_status.sv ./src/hdl/alu.sv ./src/sim/alu_%.sv ./src/enum/alu_op.sv
	verilator --binary -j 0 -Wall -cc $^ --top-module alu_$* --timing +incdir+./src/enum

out/sim:
	mkdir -p ./out/sim

run_alu_16_tb: obj_dir/Valu_16_tb out/sim
	./$<

clean:
	rm -rf ./obj_dir/ ./out

# end
