// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vaxi_wrapper.h for the primary calling header

#include "Vaxi_wrapper__pch.h"

void Vaxi_wrapper___024root___ctor_var_reset(Vaxi_wrapper___024root* vlSelf);

Vaxi_wrapper___024root::Vaxi_wrapper___024root(Vaxi_wrapper__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vaxi_wrapper___024root___ctor_var_reset(this);
}

void Vaxi_wrapper___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vaxi_wrapper___024root::~Vaxi_wrapper___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
