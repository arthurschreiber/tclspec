namespace eval Spec {
    oo::class create Matchers {
        # Current evaluation level, used to determine the correct
        # level blocks passed to a matcher have to be executed at.
        self method eval_level { {level {}} } {
            my variable eval_level

            if { ![info exists eval_level] } {
                set eval_level 1
            }

            if { $level == "" } {
                return $eval_level
            } else {
                set eval_level $level
            }
        }

        self method expect { actual to matcher args } {
            # Store the parent stack level, so that blocks passed to
            # matchers are executed in the correct scope.
            ::Spec::Matchers eval_level "#[expr { [info level] - 2 }]"

            set positive true

            # Negative Expectation
            if { $matcher == "not" } {
                set positive false
                set matcher [lindex $args 0]
                set args [lrange $args 1 end]
            }

            if { $matcher != "expect" && $matcher in [info object methods ::Spec::Matchers] } {
                set matcher [::Spec::Matchers $matcher {*}$args]
            } else {
                error "Unknown Matcher: $matcher"
            }

            if { $positive } {
                ::Spec::PositiveExpectationHandler handle_matcher $actual $matcher
            } else {
                ::Spec::NegativeExpectationHandler handle_matcher $actual $matcher
            }
        }
    }
}

source [file join [file dirname [info script]] "matchers/base_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/be_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/be_within_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/change_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/equal_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/raise_error_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/satisfy_matcher.tcl"]
