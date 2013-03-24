namespace eval ::Spec::Mocks::Tcl {
    namespace path ::Spec::Mocks
}

namespace eval ::Spec::Mocks::TclOO {
    namespace path ::Spec::Mocks
}

source [file join [file dirname [info script]] "tcl" "doubler.tcl"]
source [file join [file dirname [info script]] "tcl" "error_generator.tcl"]
source [file join [file dirname [info script]] "tcl" "proc_double.tcl"]

source [file join [file dirname [info script]] "tcloo" "error_generator.tcl"]
source [file join [file dirname [info script]] "tcloo" "method_double.tcl"]
source [file join [file dirname [info script]] "tcloo" "methods.tcl"]
source [file join [file dirname [info script]] "tcloo" "proxy.tcl"]
