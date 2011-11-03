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

Class SatisfyMatcher -superclass Matcher
SatisfyMatcher instproc init {} {

}
SatisfyMatcher instproc matches? { actual } {

}