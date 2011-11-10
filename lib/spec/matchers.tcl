namespace eval Spec {
    Class create Matchers

    # Current evaluation level, used to determine the correct
    # level blocks passed to a matcher have to be executed at.
    Matchers set eval_level 1
}

source [file join [file dirname [info script]] "matchers/base_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/be_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/change_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/equal_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/raise_error_matcher.tcl"]
source [file join [file dirname [info script]] "matchers/satisfy_matcher.tcl"]