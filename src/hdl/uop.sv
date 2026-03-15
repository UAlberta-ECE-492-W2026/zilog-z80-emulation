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

                        /* PC ops */
                        pc_m2,
                        pc_m1,
                        pc_next,

                        /* sp ops */
                        sp_m1,
                        sp_p2
                        } uop_t ;
endpackage;
