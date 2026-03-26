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
                        pc_m2,
                        pc_m1,
                        pc_next,

                        /* sp ops */
                        sp_m1,
                        sp_m1_2, /* the second stack pointer reduce in seq */
                        sp_p2,

                        /* load related */
                        ld_reg_a_reg_b,
                        ld_reg_a_imm_0,
                        ld_reg_a_imm_1,
                        ld_reg_b_imm_1,

                        read_mrbuff_reg_b_imm_0,
                        read_mbuff_mrbuff,
                        read16_reg_a_reg_b_imm_0,

                        /* write control */
                        write_reg_bH,
                        write_reg_bL,
                        write_mrbuffL_p1,
                        write_imm_1H,
                        write_imm_1L,

                        /* buffer control */
                        buff_addr_reg_a,
                        buff_addr_reg_a_2,
                        buff_addr_reg_a_imm_1,

                        /* exchange */
                        ex_de_hl,
                        ex_af_afp,
                        exx,

                        /* arithmetic */
                        add_reg_a_reg_b,
                        add_reg_a_imm_1,
                        adc_reg_a_reg_b,
                        adc_reg_a_imm_1,
                        sub_reg_a_reg_b,
                        sub_reg_a_imm_1,
                        sbc_reg_a_reg_b,
                        sbc_reg_a_imm_1,
                        dec_reg_b,

                        /* logical */
                        or_reg_a_reg_b,

                        rl_reg_a

                        } uop_t ;
endpackage;
