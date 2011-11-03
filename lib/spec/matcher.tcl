package require XOTcl
namespace import xotcl::*

Class Matcher

# Current evaluation level, used to determine the correct
# level blocks passed to a matcher have to be executed at.
Matcher set eval_level 1

Matcher instproc init { expected } {
    my set expected $expected
}
Matcher instproc matches? { actual } {
    my set actual $actual
}
Matcher instproc does_not_match? { actual } {
  expr { ![my matches? $actual] }
}
Matcher instproc positive_failure_message {} {

}
Matcher instproc negative_failure_message {} {

}

Class EqualMatcher -superclass Matcher
EqualMatcher instproc matches? { actual } {
  expr { [next] == [my set expected] }
}
EqualMatcher instproc positive_failure_message {} {
    return "Expected <[my set actual]> to equal <[my set expected]>"
}
EqualMatcher instproc negative_failure_message {} {
    return "Expected <[my set actual]> to not equal <[my set expected]>"
}

Class BeTrueMatcher -superclass Matcher
BeTrueMatcher instproc init {} {

}
BeTrueMatcher instproc matches? { actual } {
    string is true [next]
}
BeTrueMatcher instproc positive_failure_message {} {
    return "Expected [my set actual] to be true"
}
BeTrueMatcher instproc negative_failure_message {} {
    return "Expected [my set actual] to not be true"
}

Class BeFalseMatcher -superclass Matcher
BeFalseMatcher instproc init {} {

}
BeFalseMatcher instproc matches? { actual } {
    string is false [next]
}
BeFalseMatcher instproc positive_failure_message {} {
    return "Expected [my set actual] to be false"
}
BeFalseMatcher instproc negative_failure_message {} {
    return "Expected [my set actual] to not be false"
}

Class BeComparedToMatcher -superclass Matcher
BeComparedToMatcher instproc init { operand operator } {
    my set operand $operand
    my set operator $operator
}
BeComparedToMatcher instproc matches? { actual } {
    expr "\{[next]\} [my set operator] \{[my set operand]\}"
}
BeComparedToMatcher instproc positive_failure_message {} {
    return "Expected [my set actual] to be [my set operator] [my set operand]"
}
BeComparedToMatcher instproc negative_failure_message {} {
    return "Expected [my set actual] to not be [my set operator] [my set operand]"
}

Class ChangeMatcher -superclass Matcher
ChangeMatcher instproc init { expected args } {
    next $expected

    if { [dict exists $args by] } {
        my set expected_delta [dict get $args by]
    }
}

ChangeMatcher instproc matches? { actual } {
    my set actual $actual

    my set actual_before [uplevel [Matcher set eval_level] [my set expected]]
    uplevel [Matcher set eval_level] $actual
    my set actual_after [uplevel [Matcher set eval_level] [my set expected]]

    expr { [my changed?] && [my matches_expected_delta?] }
}

ChangeMatcher instproc does_not_match? { actual } {
    my set actual $actual

    my set actual_before [uplevel [Matcher set eval_level] [my set expected]]
    uplevel [Matcher set eval_level] $actual
    my set actual_after [uplevel [Matcher set eval_level] [my set expected]]

    expr { ![my changed?] || ![my matches_expected_delta?] }
}

ChangeMatcher instproc matches_expected_delta? { } {
    expr { [my exists expected_delta] ? [my actual_delta] == [my set expected_delta] : true }
}

ChangeMatcher instproc actual_delta {} {
    expr { [my set actual_after] - [my set actual_before] }
}

ChangeMatcher instproc changed? { } {
    expr { [my set actual_before] != [my set actual_after] }
}

ChangeMatcher instproc positive_failure_message {} {
    if { [my exists expected_delta] } {
        return "{[my set expected]} should have been changed by <[my set expected_delta]>, but was changed by <[my actual_delta]>"
    } else {
        return "{[my set expected]} should have changed, but is still <[my set actual_before]>"
    }
}

Class RaiseErrorMatcher -superclass Matcher
RaiseErrorMatcher instproc init { args } {

}

RaiseErrorMatcher instproc matches? { actual } {
    next
    set rc [catch [list uplevel [Matcher set eval_level] $actual] value]
    expr { $rc == 1 }
}

Class SatisfyMatcher -superclass Matcher
SatisfyMatcher instproc init { block } {
    my set block $block
}
SatisfyMatcher instproc matches? { actual } {
    my instvar block
    my set actual $actual

    if { [llength $block] == 2 } {
        uplevel [Matcher set eval_level] [list set [lindex $block 0] $actual]
        # TODO: Add correct "return" handling here
        set return_value [uplevel [Matcher set eval_level] [lindex $block end]]
        uplevel [Matcher set eval_level] [list unset [lindex $block 0]]
        return [string is true $return_value]
    } elseif { [llength $block] == 1 } {
        # TODO: Add correct "return" handling here
        uplevel $block
    } else {

    }
}