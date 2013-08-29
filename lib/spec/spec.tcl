package provide spec 0.1

package require nx
package require nx::trait
package require "TclOO" 1.0
package require "TclOO::ext"
package require at_exit
package require try

namespace eval Spec {
    namespace import ::at_exit::*
}

source [file join [file dirname [info script]] "configuration.tcl"]
source [file join [file dirname [info script]] "dsl.tcl"]
source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "matchers.tcl"]
source [file join [file dirname [info script]] "mocks.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]
source [file join [file dirname [info script]] "world.tcl"]

oo::class create Spec {
    self method world {} {
        my variable world

        if { [info exists world] } {
            set world
        } else {
            set world [::Spec::World new]
        }
    }

    self method configuration {} {
        my variable configuration

        if { [info exists configuration] } {
            return $configuration
        } else {
            set configuration [::Spec::Configuration new]
        }
    }

    self method configure { block } {
        uplevel [list apply $block [my configuration]]
    }

    self method require { filename } {
        my variable sourced

        if { ![info exists sourced] } {
            set sourced [list]
        }

        if { !($filename in $sourced) } {
            uplevel 1 [list source $filename]
            lappend sourced $filename
        }
    }
}
