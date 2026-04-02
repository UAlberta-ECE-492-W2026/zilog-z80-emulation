// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaxi_wrapper.h for the primary calling header

#include "Vaxi_wrapper__pch.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vaxi_wrapper___024root___eval_triggers__ico(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_triggers__ico\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VicoFirstIteration)));
    vlSelfRef.__VicoFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vaxi_wrapper___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
}

bool Vaxi_wrapper___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vaxi_wrapper___024root___ico_sequent__TOP__0(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___ico_sequent__TOP__0\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready 
        = ((IData)(vlSelfRef.s00_axi_awvalid) & ((IData)(vlSelfRef.s00_axi_wvalid) 
                                                 & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready) 
                                                    & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready))));
}

void Vaxi_wrapper___024root___eval_ico(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_ico\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered[0U])) {
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready 
            = ((IData)(vlSelfRef.s00_axi_awvalid) & 
               ((IData)(vlSelfRef.s00_axi_wvalid) & 
                ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready) 
                 & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready))));
    }
}

bool Vaxi_wrapper___024root___eval_phase__ico(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_phase__ico\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    Vaxi_wrapper___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = Vaxi_wrapper___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        Vaxi_wrapper___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vaxi_wrapper___024root___eval_triggers__act(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_triggers__act\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((((IData)(vlSelfRef.s00_axi_aclk) 
                                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__s00_axi_aclk__0))) 
                                                      << 2U) 
                                                     | ((((IData)(vlSelfRef.reset) 
                                                          & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__reset__0))) 
                                                         << 1U) 
                                                        | ((IData)(vlSelfRef.clk) 
                                                           & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__clk__0)))))));
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
    vlSelfRef.__Vtrigprevexpr___TOP__s00_axi_aclk__0 
        = vlSelfRef.s00_axi_aclk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vaxi_wrapper___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vaxi_wrapper___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vaxi_wrapper___024root___nba_sequent__TOP__0(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___nba_sequent__TOP__0\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*2:0*/ __Vdly__axi_wrapper__DOT__div_count;
    __Vdly__axi_wrapper__DOT__div_count = 0;
    CData/*0:0*/ __Vdly__axi_wrapper__DOT__pixel_clk;
    __Vdly__axi_wrapper__DOT__pixel_clk = 0;
    // Body
    __Vdly__axi_wrapper__DOT__div_count = vlSelfRef.axi_wrapper__DOT__div_count;
    __Vdly__axi_wrapper__DOT__pixel_clk = vlSelfRef.axi_wrapper__DOT__pixel_clk;
    if (vlSelfRef.reset) {
        __Vdly__axi_wrapper__DOT__div_count = 0U;
        __Vdly__axi_wrapper__DOT__pixel_clk = 0U;
    } else {
        __Vdly__axi_wrapper__DOT__div_count = ((4U 
                                                == (IData)(vlSelfRef.axi_wrapper__DOT__div_count))
                                                ? 0U
                                                : (7U 
                                                   & ((IData)(1U) 
                                                      + (IData)(vlSelfRef.axi_wrapper__DOT__div_count))));
        if (((2U == (IData)(vlSelfRef.axi_wrapper__DOT__div_count)) 
             | (4U == (IData)(vlSelfRef.axi_wrapper__DOT__div_count)))) {
            __Vdly__axi_wrapper__DOT__pixel_clk = (1U 
                                                   & (~ (IData)(vlSelfRef.axi_wrapper__DOT__pixel_clk)));
        }
    }
    vlSelfRef.axi_wrapper__DOT__div_count = __Vdly__axi_wrapper__DOT__div_count;
    vlSelfRef.axi_wrapper__DOT__pixel_clk = __Vdly__axi_wrapper__DOT__pixel_clk;
}

void Vaxi_wrapper___024root___nba_sequent__TOP__1(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___nba_sequent__TOP__1\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*2:0*/ __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 0;
    CData/*0:0*/ __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 0;
    CData/*2:0*/ __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = 0;
    CData/*4:0*/ __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count = 0;
    CData/*7:0*/ __VdlyVal__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0;
    __VdlyVal__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 = 0;
    CData/*3:0*/ __VdlyDim0__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0;
    __VdlyDim0__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 = 0;
    CData/*0:0*/ __VdlySet__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0;
    __VdlySet__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 = 0;
    // Body
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read 
        = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write 
        = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid 
        = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count 
        = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count;
    __VdlySet__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 = 0U;
    if (vlSelfRef.s00_axi_aresetn) {
        if (((((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en) 
               & (~ (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full))) 
              & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en)) 
             & (~ (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty)))) {
            __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count 
                = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count;
        } else if (((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en) 
                    & (~ (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full)))) {
            __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count 
                = (0x0000001fU & ((IData)(1U) + (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)));
        } else if (((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en) 
                    & (~ (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty)))) {
            __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count 
                = (0x0000001fU & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count) 
                                  - (IData)(1U)));
        }
        if ((1U & (~ ((((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en) 
                        & (0x10U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count))) 
                       & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en)) 
                      & (0U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))))) {
            if ((1U & (~ ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en) 
                          & (0x10U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))))) {
                if (((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en) 
                     & (0U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))) {
                    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr 
                        = (0x0000000fU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr)));
                }
            }
            if (((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en) 
                 & (0x10U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))) {
                __VdlyVal__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_data_in;
                __VdlyDim0__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr;
                __VdlySet__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0 = 1U;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr 
                    = (0x0000000fU & ((IData)(1U) + (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr)));
            }
        }
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg 
            = ((0xfffffffcU & vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg) 
               | (((0x10U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)) 
                   << 1U) | (0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count))));
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en = 0U;
        if ((((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready) 
              & (0U == (0x0cU & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awaddr)))) 
             & (0x10U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))) {
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en = 1U;
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_data_in 
                = (0x000000ffU & vlSelfRef.s00_axi_wdata);
        }
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en = 0U;
        if (((((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready) 
               & (IData)(vlSelfRef.s00_axi_arvalid)) 
              & (0U == (0x0cU & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr)))) 
             & (0U != (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count)))) {
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en = 1U;
        }
        if ((0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write))) {
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = 1U;
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready = 1U;
            __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 1U;
        } else if ((1U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write))) {
            if (((IData)(vlSelfRef.s00_axi_awvalid) 
                 & (IData)(vlSelfRef.s00_axi_awready))) {
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awaddr 
                    = vlSelfRef.s00_axi_awaddr;
                if (vlSelfRef.s00_axi_wvalid) {
                    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = 1U;
                    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 1U;
                    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 1U;
                } else {
                    if (((IData)(vlSelfRef.s00_axi_bready) 
                         & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid))) {
                        __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 0U;
                    }
                    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = 0U;
                    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 2U;
                }
            } else {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
                if (((IData)(vlSelfRef.s00_axi_bready) 
                     & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid))) {
                    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 0U;
                }
            }
        } else if ((2U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write))) {
            if (vlSelfRef.s00_axi_wvalid) {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 1U;
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 1U;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = 1U;
            } else {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
                if (((IData)(vlSelfRef.s00_axi_bready) 
                     & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid))) {
                    __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 0U;
                }
            }
        }
        if ((0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read))) {
            __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = 3U;
            vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready = 1U;
        } else if ((3U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read))) {
            if (((IData)(vlSelfRef.s00_axi_arvalid) 
                 & (IData)(vlSelfRef.s00_axi_arready))) {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = 4U;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr 
                    = vlSelfRef.s00_axi_araddr;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid = 1U;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready = 0U;
            } else {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
            }
        } else if ((4U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read))) {
            if (((IData)(vlSelfRef.s00_axi_rvalid) 
                 & (IData)(vlSelfRef.s00_axi_rready))) {
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid = 0U;
                vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready = 1U;
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = 3U;
            } else {
                __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read 
                    = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
            }
        }
    } else {
        __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_data_in = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en = 0U;
        __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awaddr = 0U;
        __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid = 0U;
        __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = 0U;
    }
    if ((1U & (~ (IData)(vlSelfRef.s00_axi_aresetn)))) {
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp = 0U;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp = 0U;
    }
    if (__VdlySet__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0) {
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo[__VdlyDim0__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0] 
            = __VdlyVal__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo__v0;
    }
    vlSelfRef.s00_axi_bresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp;
    vlSelfRef.s00_axi_rresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count 
        = __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty 
        = (0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full 
        = (0x10U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write 
        = __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid 
        = __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read 
        = __Vdly__axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read;
    vlSelfRef.s00_axi_bvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    vlSelfRef.s00_axi_awready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready;
    vlSelfRef.s00_axi_wready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready 
        = ((IData)(vlSelfRef.s00_axi_awvalid) & ((IData)(vlSelfRef.s00_axi_wvalid) 
                                                 & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready) 
                                                    & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready))));
    vlSelfRef.s00_axi_arready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready;
    vlSelfRef.s00_axi_rvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid;
    vlSelfRef.s00_axi_rdata = ((0U == (3U & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                             >> 2U)))
                                ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo
                               [vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr]
                                : ((1U == (3U & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                                 >> 2U)))
                                    ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg
                                    : 0U));
}

void Vaxi_wrapper___024root___eval_nba(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_nba\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*2:0*/ __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count;
    __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count = 0;
    CData/*0:0*/ __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk;
    __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk = 0;
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count 
            = vlSelfRef.axi_wrapper__DOT__div_count;
        __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk 
            = vlSelfRef.axi_wrapper__DOT__pixel_clk;
        if (vlSelfRef.reset) {
            __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count = 0U;
            __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk = 0U;
        } else {
            __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count 
                = ((4U == (IData)(vlSelfRef.axi_wrapper__DOT__div_count))
                    ? 0U : (7U & ((IData)(1U) + (IData)(vlSelfRef.axi_wrapper__DOT__div_count))));
            if (((2U == (IData)(vlSelfRef.axi_wrapper__DOT__div_count)) 
                 | (4U == (IData)(vlSelfRef.axi_wrapper__DOT__div_count)))) {
                __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk 
                    = (1U & (~ (IData)(vlSelfRef.axi_wrapper__DOT__pixel_clk)));
            }
        }
        vlSelfRef.axi_wrapper__DOT__div_count = __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__div_count;
        vlSelfRef.axi_wrapper__DOT__pixel_clk = __Vinline__nba_sequent__TOP__0___Vdly__axi_wrapper__DOT__pixel_clk;
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vaxi_wrapper___024root___nba_sequent__TOP__1(vlSelf);
    }
}

void Vaxi_wrapper___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vaxi_wrapper___024root___eval_phase__act(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_phase__act\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vaxi_wrapper___024root___eval_triggers__act(vlSelf);
    Vaxi_wrapper___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vaxi_wrapper___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vaxi_wrapper___024root___eval_phase__nba(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_phase__nba\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vaxi_wrapper___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vaxi_wrapper___024root___eval_nba(vlSelf);
        Vaxi_wrapper___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vaxi_wrapper___024root___eval(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            Vaxi_wrapper___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
            VL_FATAL_MT("axi_wrapper.sv", 8, "", "Input combinational region did not converge after 100 tries");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
    } while (Vaxi_wrapper___024root___eval_phase__ico(vlSelf));
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vaxi_wrapper___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("axi_wrapper.sv", 8, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vaxi_wrapper___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("axi_wrapper.sv", 8, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vaxi_wrapper___024root___eval_phase__act(vlSelf));
    } while (Vaxi_wrapper___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vaxi_wrapper___024root___eval_debug_assertions(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_debug_assertions\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");
    }
    if (VL_UNLIKELY(((vlSelfRef.reset & 0xfeU)))) {
        Verilated::overWidthError("reset");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_aclk & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_aclk");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_aresetn & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_aresetn");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_awaddr & 0xf0U)))) {
        Verilated::overWidthError("s00_axi_awaddr");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_awprot & 0xf8U)))) {
        Verilated::overWidthError("s00_axi_awprot");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_awvalid & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_awvalid");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_wstrb & 0xf0U)))) {
        Verilated::overWidthError("s00_axi_wstrb");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_wvalid & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_wvalid");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_bready & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_bready");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_araddr & 0xf0U)))) {
        Verilated::overWidthError("s00_axi_araddr");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_arprot & 0xf8U)))) {
        Verilated::overWidthError("s00_axi_arprot");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_arvalid & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_arvalid");
    }
    if (VL_UNLIKELY(((vlSelfRef.s00_axi_rready & 0xfeU)))) {
        Verilated::overWidthError("s00_axi_rready");
    }
}
#endif  // VL_DEBUG
