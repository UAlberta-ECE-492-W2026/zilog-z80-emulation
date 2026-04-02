// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaxi_wrapper.h for the primary calling header

#include "Vaxi_wrapper__pch.h"

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_static(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_static\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
    vlSelfRef.__Vtrigprevexpr___TOP__s00_axi_aclk__0 
        = vlSelfRef.s00_axi_aclk;
}

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_initial(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_initial\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_final(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_final\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vaxi_wrapper___024root___eval_phase__stl(Vaxi_wrapper___024root* vlSelf);

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_settle(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_settle\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vaxi_wrapper___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("axi_wrapper.sv", 8, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vaxi_wrapper___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_triggers__stl(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_triggers__stl\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vaxi_wrapper___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vaxi_wrapper___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vaxi_wrapper___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vaxi_wrapper___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vaxi_wrapper___024root___stl_sequent__TOP__0(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___stl_sequent__TOP__0\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.s00_axi_awready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready;
    vlSelfRef.s00_axi_wready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready;
    vlSelfRef.s00_axi_bresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp;
    vlSelfRef.s00_axi_bvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
    vlSelfRef.s00_axi_arready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready;
    vlSelfRef.s00_axi_rresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp;
    vlSelfRef.s00_axi_rvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid;
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty 
        = (0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full 
        = (0x10U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
    vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready 
        = ((IData)(vlSelfRef.s00_axi_awvalid) & ((IData)(vlSelfRef.s00_axi_wvalid) 
                                                 & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready) 
                                                    & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready))));
    vlSelfRef.s00_axi_rdata = ((0U == (3U & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                             >> 2U)))
                                ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo
                               [vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr]
                                : ((1U == (3U & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                                 >> 2U)))
                                    ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg
                                    : 0U));
}

VL_ATTR_COLD void Vaxi_wrapper___024root___eval_stl(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_stl\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        vlSelfRef.s00_axi_awready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready;
        vlSelfRef.s00_axi_wready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready;
        vlSelfRef.s00_axi_bresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp;
        vlSelfRef.s00_axi_bvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid;
        vlSelfRef.s00_axi_arready = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready;
        vlSelfRef.s00_axi_rresp = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp;
        vlSelfRef.s00_axi_rvalid = vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid;
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty 
            = (0U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full 
            = (0x10U == (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count));
        vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready 
            = ((IData)(vlSelfRef.s00_axi_awvalid) & 
               ((IData)(vlSelfRef.s00_axi_wvalid) & 
                ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready) 
                 & (IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready))));
        vlSelfRef.s00_axi_rdata = ((0U == (3U & ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                                 >> 2U)))
                                    ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo
                                   [vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr]
                                    : ((1U == (3U & 
                                               ((IData)(vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr) 
                                                >> 2U)))
                                        ? vlSelfRef.axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg
                                        : 0U));
    }
}

VL_ATTR_COLD bool Vaxi_wrapper___024root___eval_phase__stl(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___eval_phase__stl\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vaxi_wrapper___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vaxi_wrapper___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vaxi_wrapper___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vaxi_wrapper___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vaxi_wrapper___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vaxi_wrapper___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vaxi_wrapper___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vaxi_wrapper___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(posedge reset)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(posedge s00_axi_aclk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vaxi_wrapper___024root___ctor_var_reset(Vaxi_wrapper___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vaxi_wrapper___024root___ctor_var_reset\n"); );
    Vaxi_wrapper__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16707436170211756652ull);
    vlSelf->reset = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9928399931838511862ull);
    vlSelf->s00_axi_aclk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1333367053735230840ull);
    vlSelf->s00_axi_aresetn = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2019217215102204456ull);
    vlSelf->s00_axi_awaddr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5153858865585819133ull);
    vlSelf->s00_axi_awprot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 2430969077013310252ull);
    vlSelf->s00_axi_awvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17531152074413420496ull);
    vlSelf->s00_axi_awready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3603308820676859196ull);
    vlSelf->s00_axi_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5984703480291183175ull);
    vlSelf->s00_axi_wstrb = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 11530345016792716769ull);
    vlSelf->s00_axi_wvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1467721884610688513ull);
    vlSelf->s00_axi_wready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11930594627656942751ull);
    vlSelf->s00_axi_bresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14229025281196538815ull);
    vlSelf->s00_axi_bvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14878182407511098513ull);
    vlSelf->s00_axi_bready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 577792738055384578ull);
    vlSelf->s00_axi_araddr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 18134795301532946466ull);
    vlSelf->s00_axi_arprot = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 6890977455242278746ull);
    vlSelf->s00_axi_arvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11756476956098685804ull);
    vlSelf->s00_axi_arready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7061865305102273770ull);
    vlSelf->s00_axi_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9806031628529967673ull);
    vlSelf->s00_axi_rresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 8395809698363463622ull);
    vlSelf->s00_axi_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17650780556442765165ull);
    vlSelf->s00_axi_rready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16088668673137762006ull);
    vlSelf->axi_wrapper__DOT__div_count = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 726734243709632617ull);
    vlSelf->axi_wrapper__DOT__pixel_clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1364225636097771292ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_empty = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9063964212290708815ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_full = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17090813646145382883ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_r_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6227165968881875329ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_w_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14566307149772108744ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_data_in = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 10046902585902719745ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awaddr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 3928517109103811298ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_awready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11112281501411856586ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_wready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8860485744233162391ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 13880709875381647324ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_bvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1921053311615689969ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_araddr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 5115135862613598447ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_arready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5662608204031180624ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rresp = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 12190249096694799774ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__axi_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6747238715578778909ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__fifo_status_reg = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9260712661062311544ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_write = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17775555811325411432ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__state_read = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 489867615995444260ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__write_ready = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5865957117584309244ull);
    for (int __Vi0 = 0; __Vi0 < 16; ++__Vi0) {
        vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__fifo[__Vi0] = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 1844054923077412880ull);
    }
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__w_ptr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 7762424294984081400ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__r_ptr = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 8841481598358831932ull);
    vlSelf->axi_wrapper__DOT__axi_wrapper_slave_lite_v1_0_S00_AXI_inst__DOT__kb_fifo__DOT__count = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 6345080076853063213ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__reset__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__s00_axi_aclk__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
