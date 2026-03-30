`timescale 1ns/1ps

package uop;
    /**
     enum for the uop (micro-operation). These represents the states that the
     controller may take, which in turn defines the output of the controller.

     This enum is primarily used by the controller next state logic and the output
     logic.
     */
    typedef enum [7:0] {invalid, //0
                        reset, //1

                        nop, //2
                        fetch, //3
                        commit_fetch, //4

                        /* PC ops */
                        pc_m2, //5
                        pc_m1, //6
                        pc_next, //7

                        /* sp ops */
                        sp_m1, //8
                        sp_m1_2, //9 /* the second stack pointer reduce in seq */
                        sp_p2, //A

                        /* load related */
                        ld_reg_a_reg_b, //B
                        ld_reg_a_imm_0, //C
                        ld_reg_a_imm_1, //D
                        ld_reg_b_imm_1, //E

                        read_mrbuff_reg_b_imm_0, //F
                        read_mbuff_mrbuff, //10
                        read16_reg_a_reg_b_imm_0, //11

                        /* write control */
                        write_reg_bH, //12
                        write_reg_bL, //13
                        write_mrbuffL_p1, //14
                        write_imm_0, //15
                        write_imm_1H, //16
                        write_imm_1L, //17

                        /* buffer control */
                        buff_addr_reg_a,//18
                        buff_addr_reg_a_2,//19
                        buff_addr_reg_a_imm_1,//1A

                        /* exchange */
                        ex_de_hl,//1B
                        ex_af_afp,//1C
                        exx,//1D

                        /* arithmetic */
                        add_reg_a_reg_b,//1E
                        add_reg_a_imm_1,//1F
                        adc_reg_a_reg_b,//20
                        adc_reg_a_imm_1,//21
                        sub_reg_a_reg_b,//22
                        sub_reg_a_imm_1,//23
                        sbc_reg_a_reg_b,//24
                        sbc_reg_a_imm_1,//25
                        dec_reg_b,//26

                        /* logical */
                        or_reg_a_reg_b,//27

                        rl_reg_a//28

                        } uop_t ;
endpackage;
