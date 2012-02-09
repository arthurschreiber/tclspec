package provide spec 0.1

package require nx
package require at_exit
package require try

namespace eval Spec {
    namespace import ::tcl::control::*
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

nx::Class create Spec {
    :require namespace
    :class property [list world [::Spec::World new]]
    :class property [list configuration [Spec::Configuration new]]

    :public class method configure { block } {
        uplevel [list set [lindex $block 0] ${:configuration}]
        uplevel [lindex $block 1]
        uplevel [list unset [lindex $block 0]]
    }
}
