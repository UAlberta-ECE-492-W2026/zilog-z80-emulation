##
# 8 Bit ALU
#
# @file
# @version 0.1


.PHONY: clean

obj_dir/Valu_8_tb: ./src/hdl/alu_8.v ./src/sim/alu_8_tb.v
	verilator --binary -j 0 -Wall -cc ./src/hdl/alu_8.v ./src/sim/alu_8_tb.v --top-module alu_8_tb --trace-vcd --timing
	mkdir -p ./out/sim/

run_alu_8_tb: obj_dir/Valu_8_tb
	./obj_dir/Valu_8_tb

clean:
	rm -rf ./obj_dir/

# end
