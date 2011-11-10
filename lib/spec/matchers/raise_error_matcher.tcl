namespace eval Spec {
    namespace eval Matchers {
        ::Spec::Matchers proc raise_error { args } {
            ::Spec::Matchers::RaiseErrorMatcher new [list -init {*}$args]
        }

        Class RaiseErrorMatcher -superclass BaseMatcher
        RaiseErrorMatcher instproc init { {-code NONE} -message } {
            my set expected_code $code

            if { [info exists message]} {
                my set expected_message $message
            }
        }

        RaiseErrorMatcher instproc matches? { actual } {
            next

            my set raised_expected_code false
            my set with_expected_message false

            set rc [catch [list uplevel [::Spec::Matchers set eval_level] $actual] message options]

            if { $rc != 1 && $rc != 2 } {
                return false
            }

            my set actual_code $::errorCode
            my set actual_message $message
            if { $rc == 2 } {
                my set actual_code [dict get $options -errorcode]
            }


            my set with_expected_message [my verify_message $message]

            if { [my set expected_code] == "NONE" || [my set expected_code] == [my set actual_code] } {
                my set raised_expected_code true
            }

            if { [my set raised_expected_code] && [my set with_expected_message] } {
                return true
            } else {
                return false
            }
        }

        RaiseErrorMatcher instproc verify_message { message } {
            if { [my exists expected_message ]} {
                expr { [my set expected_message] == $message }
            } else {
                return true
            }
        }

        RaiseErrorMatcher instproc positive_failure_message { } {
            return "expected [my expected_error][my given_error]"
        }

        RaiseErrorMatcher instproc negative_failure_message { } {
            return "expected no [my expected_error][my given_error]"
        }

        RaiseErrorMatcher instproc expected_error {} {
            if { [my exists expected_message ]} {
                return "error with code '[my set expected_code]' and message '[my set expected_message]'"
            } else {
                return "error with code '[my set expected_code]'"
            }
        }

        RaiseErrorMatcher instproc given_error {} {
            if { [my exists actual_code ]} {
                return ", got error with code '[my set actual_code]' and message '[my set actual_message]'"
            } else {
                return " but nothing was raised"
            }
        }
    }
}