package provide spec 0.1

source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "world.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]
source [file join [file dirname [info script]] "formatters/base_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/base_text_formatter.tcl"]

source [file join [file dirname [info script]] "matchers.tcl"]

Class create Spec
Spec proc world { } {
    if { ![my exists world ] } {
        my set world [Spec::World new]
    }

    my set world
}

proc describe { args } {
    set group [::Spec::ExampleGroup describe {*}$args]
    [Spec world] register $group
}

proc expect { actual to matcher args } {
    # Store the current stack level, so that blocks passed to
    # matchers are executed in the correct scope.
    ::Spec::Matchers set eval_level "#[expr { [info level] - 1 }]"

    set positive true

    # Negative Expectation
    if { $matcher == "not" } {
        set positive false
        set matcher [lindex $args 0]
        set args [lrange $args 1 end]
    }

    if { [::Spec::Matchers info procs $matcher] != "" } {
        set matcher [::Spec::Matchers $matcher {*}$args]
    } else {
        error "Unknown Matcher: $matcher"
    }

    if { $positive } {
        Spec::PositiveExpectationHandler handle_matcher $actual $matcher
    } else {
        Spec::NegativeExpectationHandler handle_matcher $actual $matcher
    }
}