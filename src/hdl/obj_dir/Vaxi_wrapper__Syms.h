// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VAXI_WRAPPER__SYMS_H_
#define VERILATED_VAXI_WRAPPER__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vaxi_wrapper.h"

// INCLUDE MODULE CLASSES
#include "Vaxi_wrapper___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vaxi_wrapper__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vaxi_wrapper* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vaxi_wrapper___024root         TOP;

    // CONSTRUCTORS
    Vaxi_wrapper__Syms(VerilatedContext* contextp, const char* namep, Vaxi_wrapper* modelp);
    ~Vaxi_wrapper__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
