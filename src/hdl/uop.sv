`timescale 1ns/1ps

package uop;
    /**
     enum for the uop (micro-operation). These represents the states that the
     controller may take, which in turn defines the output of the controller.

     This enum is primarily used by the controller next state logic and the output
     logic.
     */
    typedef enum [7:0] {invalid,
                        reset,

                        nop,
                        fetch,
                        commit_fetch,

                        /* PC ops */
                        pc_m2, // 5
                        pc_m1,
                        pc_next,

                        /* sp ops */
                        sp_m1, //8
                        sp_m1_2, /* the second stack pointer reduce in seq */
                        sp_p2,

                        /* load related */
                        ld_reg_a_reg_b, //B
                        ld_reg_a_imm_0,
                        ld_reg_a_imm_1,
                        ld_reg_b_imm_1,

                        read_mrbuff_reg_b_imm_0, //F
                        read_mrbuff_imm_1,
                        read_mbuff_mrbuff,
                        read16_reg_a_reg_b_imm_0,
                        read16_reg_a_imm_1,

                        /* write control */
                        write_reg_bH, //14
                        write_reg_bH_addr_p1,
                        write_reg_bL,
                        write_mrbuffL_p1,
                        write_mrbuffL_m1,
                        write_imm_0,
                        write_imm_1H,
                        write_imm_1H_addr_p1,
                        write_imm_1L,
                        write_obuffL,
                        write_obuffH_addr_p1,

                        /* buffer control */
                        buff_addr_reg_a, //1E
                        buff_addr_reg_a_2,
                        buff_addr_reg_a_imm_1,
                        buff_addr_reg_b_imm_1,
                        buff_addr_imm_1,

                        /* operand buffer */
                        ld_obuff_reg_a, //23

                        /* exchange */
                        ex_de_hl, //24
                        ex_af_afp,
                        exx,

                        /* arithmetic */
                        add_reg_a_reg_b, //27
                        add_reg_a_imm_1,
                        add_reg_a_mrbuff,
                        adc_reg_a_reg_b,
                        adc_reg_a_imm_1,
                        adc_reg_a_mrbuff,
                        sub_reg_a_reg_b,
                        sub_reg_a_imm_1,
                        sub_reg_a_mrbuff,
                        sbc_reg_a_reg_b,
                        sbc_reg_a_imm_1,
                        sbc_reg_a_mrbuff,
                        and_reg_a_reg_b,
                        and_reg_a_imm_1,
                        and_reg_a_mrbuff,
                        or_reg_a_reg_b,
                        or_reg_a_imm_1,
                        or_reg_a_mrbuff,
                        xor_reg_a_reg_b,
                        xor_reg_a_imm_1,
                        xor_reg_a_mrbuff,
                        cp_reg_a_reg_b,
                        cp_reg_a_imm_1,
                        cp_reg_a_mrbuff,

                        dec_reg_b,

                        /* general purpose group */
                        daa, //41
                        cpl,
                        neg,
                        ccf, 
                        scf,

                        /* rotate/shift */
                        rl_reg_a

                        } uop_t ;
endpackage;
