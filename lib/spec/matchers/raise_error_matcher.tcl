namespace eval Spec {
    namespace eval Matchers {
        ::Spec::Matchers public class method raise_error { args } {
            ::Spec::Matchers::RaiseErrorMatcher new {*}$args
        }

        nx::Class create RaiseErrorMatcher -superclass BaseMatcher {
            :property {code "NONE"}
            :property message

            :public method matches? { actual } {
                next

                set :raised_expected_code false
                set :with_expected_message false

                set rc [catch [list uplevel [::Spec::Matchers eval_level] $actual] message options]

                if { $rc != 1 && $rc != 2 } {
                    return false
                }

                set :actual_code $::errorCode
                set :actual_message $message
                if { $rc == 2 } {
                    set :actual_code [dict get $options -errorcode]
                }


                set :with_expected_message [:verify_message $message]

                if { ${:code} == "NONE" || ${:code} == ${:actual_code} } {
                    set :raised_expected_code true
                }

                expr { ${:raised_expected_code} && ${:with_expected_message} }
            }

            :public method verify_message { message } {
                if { [info exists :message ]} {
                    expr { ${:message} == $message }
                } else {
                    return true
                }
            }

            :public method failure_message { } {
                return "expected [:expected_error][:given_error]"
            }

            :public method negative_failure_message { } {
                return "expected no [:expected_error][:given_error]"
            }

            :public method expected_error {} {
                if { [info exists :message ]} {
                    return "error with code '[set :code]' and message '[set :message]'"
                } else {
                    return "error with code '[set :code]'"
                }
            }

            :public method given_error {} {
                if { [info exists :actual_code ]} {
                    return ", got error with code '[set :actual_code]' and message '[set :actual_message]'"
                } else {
                    return " but nothing was raised"
                }
            }
        }
    }
}