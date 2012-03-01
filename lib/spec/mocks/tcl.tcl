namespace eval ::Spec::Mocks::Tcl {
    namespace path ::Spec::Mocks
}

source [file join [file dirname [info script]] "tcl" "doubler.tcl"]
source [file join [file dirname [info script]] "tcl" "error_generator.tcl"]
source [file join [file dirname [info script]] "tcl" "proc_double.tcl"]

namespace eval ::Spec::ExampleProcs {
    # Replace a tcl command with a custom implementation.
    proc stub_call { args } {
        ::Spec::Mocks::Tcl::Doubler stub_call {*}$args
    }

    # Replace a tcl command with a custom implementation and a
    # call expectation.
    proc mock_call { args } {
        ::Spec::Mocks::Tcl::Doubler mock_call {*}$args
    }

    # Replace a tcl command with a negative call expectation.
    proc dont_call { args } {
        ::Spec::Mocks::Tcl::Doubler dont_call {*}$args
    }
}