package provide spec 0.1

source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "world.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]
source [file join [file dirname [info script]] "formatters/base_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/base_text_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/documentation_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/progress_formatter.tcl"]

source [file join [file dirname [info script]] "matchers.tcl"]

Class create Spec
Spec proc world { } {
    if { ![my exists world ] } {
        my set world [Spec::World new]
    }

    my set world
}

proc describe { args } {
    [::Spec::ExampleGroup describe {*}$args] register
}