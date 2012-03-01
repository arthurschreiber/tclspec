namespace eval ::Spec::Mocks::Tcl {
    namespace path ::Spec::Mocks
}

source [file join [file dirname [info script]] "tcl" "doubler.tcl"]
source [file join [file dirname [info script]] "tcl" "error_generator.tcl"]
source [file join [file dirname [info script]] "tcl" "proc_double.tcl"]