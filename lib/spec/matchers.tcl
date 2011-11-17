namespace eval Spec {
    namespace eval Matchers {
        namespace path ::Spec
    }

    Class create Matchers

    # Current evaluation level, used to determine the correct
    # level blocks passed to a matcher have to be executed at.
    Matchers set eval_level 1

    Matchers proc expect { actual to matcher args } {
        # Store the parent stack level, so that blocks passed to
        # matchers are executed in the correct scope.
        ::Spec::Matchers set eval_level "#[expr { [info level] - 1 }]"

        set positive true

        # Negative Expectation
        if { $matcher == "not" } {
            set positive false
            set matcher [lindex $args 0]
            set args [lrange $args 1 end]
        }

        if { $matcher != "expect" && [::Spec::Matchers info procs $matcher] != "" } {
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
}

source [file join [file dirname [info script]] "matchers/base_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/be_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/change_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/equal_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/raise_error_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/satisfy_matcher.tcl"]