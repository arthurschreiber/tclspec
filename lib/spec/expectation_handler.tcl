package require XOTcl
namespace import xotcl::*

Class Expectations
Expectations proc fail_with { message } {
    return -code error -errorcode "EXPECTATION_NOT_MET" $message
}

Class PositiveExpectationHandler
PositiveExpectationHandler proc handle_matcher { actual matcher } {
    if { [$matcher matches? $actual] } { return }
    Expectations fail_with [$matcher positive_failure_message]
}

Class NegativeExpectationHandler
NegativeExpectationHandler proc handle_matcher { actual matcher } {
    if { [$matcher does_not_match? $actual] } { return }
    Expectations fail_with [$matcher negative_failure_message]
}