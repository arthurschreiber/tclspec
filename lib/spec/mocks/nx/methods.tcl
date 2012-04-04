namespace eval Spec::Mocks::nx {
    nx::Trait create Methods {
        # Set an expectation that this object should receive a call to the
        # given method.
        #
        # @example
        #   set logger [double "Logger"]
        #   set thing_that_logs [ThingThatLogs new -logger $logger]
        #
        #   $logger should_receive "log"
        #   $thing_that_logs do_something_that_logs_a_message
        :public method should_receive { method_name -with -and_return {-once:switch false} {-any_number_of_times:switch false} {-twice:switch false} {-never:switch false} block:optional } {
            if { [info exists block] } {
                if { [llength $block] < 3 } {
                    lappend block [uplevel 1 [list namespace current]]
                }
            } else {
                set block {}
            }

            set expectation [[:__mock_proxy] add_message_expectation $method_name $block]

            if { [info exists with] } {
                $expectation with $with
            }

            if { $once } {
                $expectation once
            }

            if { $twice } {
                $expectation twice
            }

            if { $never } {
                $expectation never
            }

            if { $any_number_of_times } {
                $expectation any_number_of_times
            }

            if { [info exists and_return] } {
                $expectation and_return $and_return
            }
        }

        # Set an expectation that this object should _not_ receive a call to
        # the given method.
        :public method should_not_receive { method_name -with } {
            set expectation [[:__mock_proxy] add_negative_message_expectation $method_name]

            if { [info exists with] } {
                $expectation with $with
            }
        }

        :public method stub { method_name -with -and_return block:optional } {
            if { [info exists block] } {
                if { [llength $block] < 3 } {
                    lappend block [uplevel 1 [list namespace current]]
                }
            } else {
                set block {}
            }

            set stub [[:__mock_proxy] add_stub $method_name $block]

            if { [info exists with] } {
                $stub with $with
            }

            if { [info exists and_return] } {
                $stub and_return $and_return
            }
        }

        :public method unstub { method_name } {
            [:__mock_proxy] remove_stub $method_name
        }

        :public method as_null_object {} {
            [:__mock_proxy] as_null_object
        }

        :public method null_object? {} {
            [:__mock_proxy] null_object?
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
                if { [:info class] == "::Spec::Mocks::nx::Mock" } {
                    set :mock_proxy [::Spec::Mocks::nx::Proxy new -object [:] -name ${:name} -options ${:options}]
                } else {
                    set :mock_proxy [::Spec::Mocks::nx::Proxy new -object [:]]
                }
            }

            return ${:mock_proxy}
        }
    }
}