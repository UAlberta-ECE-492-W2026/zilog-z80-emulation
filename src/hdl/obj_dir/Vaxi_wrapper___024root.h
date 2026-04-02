// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vaxi_wrapper.h for the primary calling header

#ifndef VERILATED_VAXI_WRAPPER___024ROOT_H_
#define VERILATED_VAXI_WRAPPER___024ROOT_H_  // guard

#include "verilated.h"


class Vaxi_wrapper__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vaxi_wrapper___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(s00_axi_aclk,0,0);
    VL_IN8(s00_axi_aresetn,0,0);
    VL_IN8(s00_axi_awaddr,3,0);
    VL_IN8(s00_axi_awprot,2,0);
    VL_IN8(s00_axi_awvalid,0,0);
    VL_OUT8(s00_axi_awready,0,0);
    VL_IN8(s00_axi_wstrb,3,0);
    VL_IN8(s00_axi_wvalid,0,0);
    VL_OUT8(s00_axi_wready,0,0);
    VL_OUT8(s00_axi_bresp,1,0);
    VL_OUT8(s00_axi_bvalid,0,0);
    VL_IN8(s00_axi_bready,0,0);
    VL_IN8(s00_axi_araddr,3,0);
    VL_IN8(s00_axi_arprot,2,0);
    VL_IN8(s00_axi_arvalid,0,0);
    VL_OUT8(s00_axi_arready,0,0);
    VL_OUT8(s00_axi_rresp,1,0);
    VL_OUT8(s00_axi_rvalid,0,0);
    VL_IN8(s00_axi_rready,0,0);
    CData/*2:0*/ axi_wrapper__DOT__div_count;
    CData/*0:0*/ axi_wrapper__DOT__pixel_clk;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en;
    CData/*7:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_data_in;
    CData/*3:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awaddr;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready;
    CData/*1:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    CData/*3:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready;
    CData/*1:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid;
    CData/*2:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
    CData/*2:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
    CData/*0:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready;
    CData/*3:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr;
    CData/*3:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr;
    CData/*4:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__reset__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__s00_axi_aclk__0;
    VL_IN(s00_axi_wdata,31,0);
    VL_OUT(s00_axi_rdata,31,0);
    IData/*31:0*/ axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 16> axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vaxi_wrapper__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vaxi_wrapper___024root(Vaxi_wrapper__Syms* symsp, const char* namep);
    ~Vaxi_wrapper___024root();
    VL_UNCOPYABLE(Vaxi_wrapper___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
