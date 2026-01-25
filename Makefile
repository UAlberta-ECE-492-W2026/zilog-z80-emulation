##
# 8 Bit ALU
#
# @file
# @version 0.1


.PHONY: clean

obj_dir/Valu_8_tb: ./src/hdl/alu.sv ./src/sim/alu_8_tb.sv
	verilator --binary -j 0 -Wall -cc $^ --top-module alu_8_tb --trace-vcd --timing
	mkdir -p ./out/sim/

obj_dir/Valu_16_tb: ./src/hdl/alu.sv ./src/sim/alu_16_tb.sv
	verilator --binary -j 0 -Wall -cc $^ --top-module alu_16_tb --trace-vcd --timing
	mkdir -p ./out/sim/

run_alu_8_tb: obj_dir/Valu_8_tb
	./obj_dir/Valu_8_tb

run_alu_16_tb: obj_dir/Valu_16_tb
	./obj_dir/Valu_8_tb

clean:
	rm -rf ./obj_dir/

# end
