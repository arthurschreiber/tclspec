namespace eval Spec {
    namespace eval Matchers {
        oo::objdefine ::Spec::Matchers method raise_error { args } {
            ::Spec::Matchers::RaiseErrorMatcher new {*}$args
        }

        oo::class create RaiseErrorMatcher {
            superclass Spec::Matchers::BaseMatcher

            constructor { args } {
                if { [dict exists $args "-code"] } {
                    set [self]::code [dict get $args "-code"]
                } else {
                    set [self]::code "NONE"
                }

                if { [dict exists $args "-message"] } {
                    set [self]::message [dict get $args "-message"]
                }
            }

            method matches? { actual } {
                my variable raised_expected_code with_expected_message code actual_code actual_message

                set raised_expected_code false
                set with_expected_message false

                set rc [catch [list uplevel [::Spec::Matchers eval_level] $actual] message options]

                if { $rc != 1 && $rc != 2 } {
                    return false
                }

                set actual_code $::errorCode
                set actual_message $message
                if { $rc == 2 } {
                    set actual_code [dict get $options -errorcode]
                }

                set with_expected_message [my verify_message $message]

                if { ${code} == "NONE" || ${code} == ${actual_code} } {
                    set raised_expected_code true
                }

                expr { ${raised_expected_code} && ${with_expected_message} }
            }

            method verify_message { message } {
                if { [info exists [self]::message ]} {
                    expr { [set [self]::message] == $message }
                } else {
                    return true
                }
            }

            method failure_message { } {
                return "expected [my expected_error][my given_error]"
            }

            method negative_failure_message { } {
                return "expected no [my expected_error][my given_error]"
            }

            method expected_error {} {
                if { [info exists [self]::message] } {
                    return "error with code '[set [self]::code]' and message '[set [self]::message]'"
                } else {
                    return "error with code '[set [self]::code]'"
                }
            }

            method given_error {} {
                if { [info exists [self]::actual_code] } {
                    return ", got error with code '[set [self]::actual_code]' and message '[set [self]::actual_message]'"
                } else {
                    return " but nothing was raised"
                }
            }
        }
    }
}
