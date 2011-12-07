namespace eval Spec {
    Class Expectations
    Expectations proc fail_with { message } {
        # Setting the return level here allows us to tweak generated backtraces
        # for expectation failures a bit. Thanks to this, the backtrace will
        # state that an error occurred during execution of "expect ...",
        # instead of during "Expectations fail_with ...".
        #
        # Also, this keeps the backtrace shorter and more focused, as we're
        # usually not concerned with what happens between the call to "expect"
        # and the generation of the expectation failure.
        #
        # TODO: The return level here is currently hard-coded, but it should be
        #       possible to determine the correct level programmatically.
        return -level 3 -code error -errorcode "EXPECTATION_NOT_MET" $message
    }

    Class PositiveExpectationHandler
    PositiveExpectationHandler proc handle_matcher { actual matcher } {
        if { [$matcher matches? $actual] } { return }
        Expectations fail_with [$matcher failure_message]
    }

    Class NegativeExpectationHandler
    NegativeExpectationHandler proc handle_matcher { actual matcher } {
        if { [$matcher does_not_match? $actual] } { return }
        Expectations fail_with [$matcher negative_failure_message]
    }
}