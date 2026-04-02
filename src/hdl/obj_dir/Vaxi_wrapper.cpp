// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vaxi_wrapper__pch.h"

//============================================================
// Constructors

Vaxi_wrapper::Vaxi_wrapper(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vaxi_wrapper__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , s00_axi_aclk{vlSymsp->TOP.s00_axi_aclk}
    , s00_axi_aresetn{vlSymsp->TOP.s00_axi_aresetn}
    , s00_axi_awaddr{vlSymsp->TOP.s00_axi_awaddr}
    , s00_axi_awprot{vlSymsp->TOP.s00_axi_awprot}
    , s00_axi_awvalid{vlSymsp->TOP.s00_axi_awvalid}
    , s00_axi_awready{vlSymsp->TOP.s00_axi_awready}
    , s00_axi_wstrb{vlSymsp->TOP.s00_axi_wstrb}
    , s00_axi_wvalid{vlSymsp->TOP.s00_axi_wvalid}
    , s00_axi_wready{vlSymsp->TOP.s00_axi_wready}
    , s00_axi_bresp{vlSymsp->TOP.s00_axi_bresp}
    , s00_axi_bvalid{vlSymsp->TOP.s00_axi_bvalid}
    , s00_axi_bready{vlSymsp->TOP.s00_axi_bready}
    , s00_axi_araddr{vlSymsp->TOP.s00_axi_araddr}
    , s00_axi_arprot{vlSymsp->TOP.s00_axi_arprot}
    , s00_axi_arvalid{vlSymsp->TOP.s00_axi_arvalid}
    , s00_axi_arready{vlSymsp->TOP.s00_axi_arready}
    , s00_axi_rresp{vlSymsp->TOP.s00_axi_rresp}
    , s00_axi_rvalid{vlSymsp->TOP.s00_axi_rvalid}
    , s00_axi_rready{vlSymsp->TOP.s00_axi_rready}
    , s00_axi_wdata{vlSymsp->TOP.s00_axi_wdata}
    , s00_axi_rdata{vlSymsp->TOP.s00_axi_rdata}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vaxi_wrapper::Vaxi_wrapper(const char* _vcname__)
    : Vaxi_wrapper(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vaxi_wrapper::~Vaxi_wrapper() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vaxi_wrapper___024root___eval_debug_assertions(Vaxi_wrapper___024root* vlSelf);
#endif  // VL_DEBUG
void Vaxi_wrapper___024root___eval_static(Vaxi_wrapper___024root* vlSelf);
void Vaxi_wrapper___024root___eval_initial(Vaxi_wrapper___024root* vlSelf);
void Vaxi_wrapper___024root___eval_settle(Vaxi_wrapper___024root* vlSelf);
void Vaxi_wrapper___024root___eval(Vaxi_wrapper___024root* vlSelf);

void Vaxi_wrapper::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vaxi_wrapper::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vaxi_wrapper___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vaxi_wrapper___024root___eval_static(&(vlSymsp->TOP));
        Vaxi_wrapper___024root___eval_initial(&(vlSymsp->TOP));
        Vaxi_wrapper___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vaxi_wrapper___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vaxi_wrapper::eventsPending() { return false; }

uint64_t Vaxi_wrapper::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vaxi_wrapper::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vaxi_wrapper___024root___eval_final(Vaxi_wrapper___024root* vlSelf);

VL_ATTR_COLD void Vaxi_wrapper::final() {
    Vaxi_wrapper___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vaxi_wrapper::hierName() const { return vlSymsp->name(); }
const char* Vaxi_wrapper::modelName() const { return "Vaxi_wrapper"; }
unsigned Vaxi_wrapper::threads() const { return 1; }
void Vaxi_wrapper::prepareClone() const { contextp()->prepareClone(); }
void Vaxi_wrapper::atClone() const {
    contextp()->threadPoolpOnClone();
}
