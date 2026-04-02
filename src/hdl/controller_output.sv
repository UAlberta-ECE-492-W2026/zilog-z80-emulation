`timescale 1ns/1ps
`include "reg_name.sv"
`include "mux_enums.sv"
`include "uop.sv"

/**
 * module that provides the signal output logic for the controller.
 */
module controller_output (
                          c_to_dp_intf.controller_output intf
                          );
    /* assignments ***************/

    always_comb begin: output_block
        intf.set_default_outputs();

        if (intf.reset) begin // output the reset output
        end
        else
          case (intf.current_state)
            uop::reset: begin
            end
            uop::nop: begin
                intf.disable_reg_w();
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_INSTRUCTION_LENGTH));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::fetch: begin
                intf.ir_en = 1;
                intf.reg_a_sel = PC;
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                intf.mem_r_en = 1;
            end
            uop::commit_fetch: begin
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
            end
            uop::pc_m2: begin
                intf.reg_a_sel = PC;
                intf.enable_and_set_reg_w(PC);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.set_imm(-2);
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::pc_m1: begin
                intf.reg_a_sel = PC;
                intf.enable_and_set_reg_w(PC);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.set_imm(-1);
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sp_m1, uop::sp_m1_2: begin
                intf.reg_a_sel = SP;
                intf.enable_and_set_reg_w(SP);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.set_imm(-1);
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sp_p2: begin
                intf.reg_a_sel = SP;
                intf.enable_and_set_reg_w(SP);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.set_imm(2);
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::pc_next: begin
                intf.enable_and_set_reg_w(PC);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_INSTRUCTION_LENGTH));
                intf.alu_16b_mode = 1;
                intf.reg_a_sel = PC;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out; // for LD A, I and LD A, R
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_a_imm_1: begin
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ld_reg_b_imm_1: begin
                intf.enable_and_set_reg_w(intf.reg_b_sel_out);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::buff_addr_reg_a, uop::buff_addr_reg_a_2: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_addr_buff_en = 1;
            end
            uop::buff_addr_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_alu_opcode(ALU_ADD, .mux_a(A_MUX_REG), .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_addr_buff_en = 1;
                intf.imm_in = {8'h00, intf.imm_0_out};
            end
            uop::buff_addr_reg_b_imm_1: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_ADD, .mux_a(A_MUX_REG), .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_addr_buff_en = 1;
                intf.imm_in = {8'h00, intf.imm_0_out};
            end
            uop::buff_addr_imm_1: begin
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_addr_buff_en = 1;
                intf.imm_in = intf.imm_1_out;
            end
            uop::ld_obuff_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.o_buff_en = 1;
            end
            uop::write_reg_bH: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::write_reg_bH_addr_p1: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED_P1;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::write_reg_bL: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::write_mrbuffL_p1: begin
                intf.set_imm(1);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 0;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::write_mrbuffL_m1: begin
                intf.set_imm(1);
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 0;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::write_imm_1L: begin
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::write_obuffL: begin
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_O_BUFF));
                intf.alu_16b_mode = 0;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::write_obuffH_addr_p1: begin
                intf.enable_and_set_alu_opcode(ALU_PASS_A, .mux_a(A_MUX_O_BUFF));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED_P1;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::write_imm_1H: begin
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::read_mrbuff_reg_b_imm_0: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.imm_0_to_imm();
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                intf.mem_read_buff_en = 1;
                intf.mem_r_en = 1;
            end
            uop::read_mrbuff_reg_b: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                intf.mem_read_buff_en = 1;
                intf.mem_r_en = 1;
            end
            uop::read_mrbuff_imm_1: begin
                intf.imm_in = intf.imm_1_out;
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.mem_read_buff_en = 1;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED;
                intf.mem_r_en = 1;
            end
            uop::read16_reg_a_reg_b_imm_0: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.imm_0_to_imm();
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_MEMORY_READ_BUFF;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED_P1;
                intf.mem_r_en = 1;
            end
            uop::read16_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.enable_and_set_alu_opcode(ALU_PASS_A,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_MEMORY_READ_BUFF;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED_P1;
                intf.mem_r_en = 1;
            end
            uop::read16_reg_a_imm_1: begin
                intf.imm_in = intf.imm_1_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel_out);
                intf.enable_and_set_alu_opcode(ALU_PASS_B, .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 1;
                intf.write_back_sel = WB_MUX_MEMORY_READ_BUFF;
                intf.mem_mux_sel = MEM_MUX_UNBUFFERED_P1;
                intf.mem_r_en = 1;
            end
            uop::read_mbuff_mrbuff: begin
                intf.mem_read_buff_en = 1;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_r_en = 1;
            end
            uop::exx: begin
                intf.exx_sig = EXX_ALL;
                intf.disable_alu();
            end
            uop::ex_de_hl: begin
                intf.exx_sig = EXX_DE_HL;
                intf.disable_alu();
            end
            uop::ex_af_afp: begin
                intf.exx_sig = EXX_AF_AFp;
                intf.disable_alu();
            end
            uop::add_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::add_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::add_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_ADD,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::adc_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_ADC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.forward_decode_16b_alu();
                intf.update_flags = intf.update_flags_out;
                intf.f_w_en = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::adc_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_ADC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::adc_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_ADC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sub_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.forward_decode_16b_alu();
                intf.update_flags = intf.update_flags_out;
                intf.f_w_en = 1;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sub_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sub_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sbc_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SBC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sbc_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_SBC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sbc_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SBC,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::and_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_AND,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::and_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_AND,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::and_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_AND,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::or_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_OR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::or_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_OR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::or_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_OR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::xor_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_XOR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::xor_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_XOR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::xor_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_XOR,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::cp_reg_a_reg_b: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.reg_b_sel = intf.reg_b_sel_out;
                intf.enable_and_set_alu_opcode(ALU_COMPARE,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
            end
            uop::cp_reg_a_imm_1: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_COMPARE,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
            end
            uop::cp_reg_a_mrbuff: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_alu_opcode(ALU_COMPARE,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_MEMORY_READ_BUFF));
                intf.forward_decode_16b_alu();
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
            end
            uop::dec_reg_b: begin
                intf.reg_a_sel = intf.reg_b_sel_out;
                intf.enable_and_set_reg_w(intf.reg_b_sel_out);
                intf.set_imm(1);
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::daa: begin
                intf.reg_a_sel = A;
                intf.enable_and_set_reg_w(A);
                intf.enable_and_set_alu_opcode(ALU_DAA,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::cpl: begin
                intf.reg_a_sel = A;
                intf.enable_and_set_reg_w(A);
                intf.enable_and_set_alu_opcode(ALU_CPL,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::neg: begin
                intf.reg_b_sel = A;
                intf.imm_in = 0;
                intf.enable_and_set_reg_w(A);
                intf.enable_and_set_alu_opcode(ALU_SUB,
                                               .mux_a(A_MUX_0),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::ccf: begin
                intf.f_op = F_CCF;
                intf.f_w_en = 1;
            end
            uop::scf: begin
                intf.f_op = F_SCF;
                intf.f_w_en = 1;
            end
            uop::rlc_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_RLC,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::rlc_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_RLC,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::rl_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_RL,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::rl_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_RL,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::rrc_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_RRC,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::rrc_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_RRC,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::rr_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_RR,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::rr_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_RR,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::sla_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SLA,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sla_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_SLA,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::sra_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SRA,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::sra_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_SRA,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::srl_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.enable_and_set_reg_w(intf.reg_a_sel);
                intf.enable_and_set_alu_opcode(ALU_SRL,
                                               .mux_a(A_MUX_REG));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
            end
            uop::srl_mbuff_mrbuff: begin
                intf.enable_and_set_alu_opcode(ALU_SRL,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_LOWER;
                intf.mem_w_en = 1;
            end
            uop::rld: begin
                intf.reg_b_sel = A;
                intf.enable_and_set_reg_w(A);
                intf.enable_and_set_alu_opcode(ALU_RLD,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::rrd: begin
                intf.reg_b_sel = A;
                intf.enable_and_set_reg_w(A);
                intf.enable_and_set_alu_opcode(ALU_RRD,
                                               .mux_a(A_MUX_MEMORY_READ_BUFF),
                                               .mux_b(B_MUX_REG));
                intf.alu_16b_mode = 1;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
                intf.write_back_sel = WB_MUX_ALU;
                intf.mem_mux_sel = MEM_MUX_BUFFERED;
                intf.mem_data_mux_sel = MEM_DATA_MUX_UPPER;
                intf.mem_w_en = 1;
            end
            uop::bit_reg_a: begin
                intf.reg_a_sel = intf.reg_a_sel_out;
                intf.imm_1_to_imm();
                intf.enable_and_set_alu_opcode(ALU_BIT,
                                               .mux_a(A_MUX_REG),
                                               .mux_b(B_MUX_IMM));
                intf.alu_16b_mode = 0;
                intf.f_w_en = 1;
                intf.update_flags = intf.update_flags_out;
            end
            default: begin
            end
          endcase; // case (current_state)
    end;

endmodule // controller_next_state
