package provide spec 0.1

package require XOTcl
package require at_exit
package require try

namespace eval Spec {
    namespace import ::xotcl::*
    namespace import ::try::*
    namespace import ::at_exit::*
}

::xotcl::Class create Spec
Spec proc world {} {
    if { ![::xotcl::my exists world ] } {
        ::xotcl::my set world [Spec::World new]
    }

    ::xotcl::my set world
}

proc describe { args } {
    [::Spec::ExampleGroup describe {*}$args] register
}

source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "matchers.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]
source [file join [file dirname [info script]] "world.tcl"]