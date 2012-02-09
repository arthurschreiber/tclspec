namespace eval Spec {
    namespace eval Mocks {
        nx::Class create MethodsMixin {
            # Set an expectation that this object should receive a call to the
            # given method.
            #
            # @example
            #   set logger [double "Logger"]
            #   set thing_that_logs [ThingThatLogs new -logger $logger]
            #
            #   $logger should_receive "log"
            #   $thing_that_logs do_something_that_logs_a_message
            :public method should_receive { method_name -with {block {}} } {
                set expectation [[:__mock_proxy] add_message_expectation $method_name $block]

                if { [info exists with] } {
                    $expectation with $with
                }
            }

            # Set an expectation that this object should _not_ receive a call to
            # the given method.
            :public method should_not_receive { method_name -with {block {}} } {
                set expectation [[:__mock_proxy] add_negative_message_expectation $method_name]

                if { [info exists with] } {
                    $expectation with $with
                }
            }

            :public method stub {} {
                error "Not implemented"
            }

            :public method unstub {} {
                error "Not implemented"
            }

            :public method as_null_object {} {
                error "Not implemented"
            }

            :public method null_object? {} {
                error "Not implemented"
            }

            # @api private
            :public method spec_verify { } {
                [:__mock_proxy] verify
            }

            # @api private
           :public method spec_reset { } {
                [:__mock_proxy] reset
            }

            :protected method __mock_proxy { } {
                if { ![info exists :mock_proxy] } {
                    if { [:info class] == "::Spec::Mocks::Mock" } {
                        set :mock_proxy [::Spec::Mocks::Proxy new -object [:] -name ${:name}]
                    } else {
                        set :mock_proxy [::Spec::Mocks::Proxy new -object [:]]
                    }
                }

                return ${:mock_proxy}
            }
        }
    }
}