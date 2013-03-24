namespace eval Spec::Mocks::TclOO {
    oo::define oo::object {
        # Set an expectation that this object should receive a call to the
        # given method.
        #
        # @example
        #   set logger [double "Logger"]
        #   set thing_that_logs [ThingThatLogs new $logger]
        #
        #   $logger should_receive "log"
        #   $thing_that_logs do_something_that_logs_a_message
        method should_receive { method_name args } {
            for {set i 0} {$i < [llength $args]} {incr i} {
                set arg [lindex $args $i]

                if { [string range $arg 0 0] == "-" } {
                    if { $arg == "-with" } {
                        set with [lindex $args $i+1]
                        incr i
                    }
                    if { $arg == "-and_return" } {
                        set and_return [lindex $args $i+1]
                        incr i
                    }

                    if { $arg == "-exactly" } {
                        set exactly [lindex $args $i+1]
                        incr i
                    }

                    if { $arg == "-at_least" } {
                        set at_least [lindex $args $i+1]
                        incr i
                    }

                    if { $arg == "-at_most" } {
                        set at_most [lindex $args $i+1]
                        incr i
                    }


                    if { $arg == "-once" } {
                        set once true
                    }

                    if { $arg == "-twice" } {
                        set twice true
                    }

                    if { $arg == "-never" } {
                        set never true
                    }

                    if { $arg == "-any_number_of_times" } {
                        set any_number_of_times true
                    }

                    # Raise an error, unknown option...
                } else {
                    set block $arg
                    # Raise an error if there are more arguments that have to be processed
                }
            }


            if { [info exists block] } {
                if { [llength $block] < 3 } {
                    lappend block [uplevel 1 [list namespace current]]
                }
            } else {
                set block {}
            }

            set expectation [[my __mock_proxy] add_message_expectation $method_name $block]

            if { [info exists with] } {
                $expectation with $with
            }

            if { [info exists once] } {
                $expectation once
            }

            if { [info exists twice] } {
                $expectation twice
            }

            if { [info exists never] } {
                $expectation never
            }

            if { [info exists any_number_of_times] } {
                $expectation any_number_of_times
            }

            if { [info exists exactly] } {
                $expectation exactly $exactly
            }

            if { [info exists at_least] } {
                $expectation at_least $at_least
            }

            if { [info exists at_most] } {
                $expectation at_most $at_most
            }

            if { [info exists and_return] } {
                $expectation and_return $and_return
            }
        }

        # Set an expectation that this object should _not_ receive a call to
        # the given method.
        method should_not_receive { method_name -with } {
            set expectation [[my __mock_proxy] add_negative_message_expectation $method_name]

            if { [info exists with] } {
                $expectation with $with
            }
        }

        method stub { method_name args } {
            for {set i 0} {$i < [llength $args]} {incr i} {
                set arg [lindex $args $i]

                if { [string range $arg 0 0] == "-" } {
                    if { $arg == "-with" } {
                        set with [lindex $args $i+1]
                        incr i
                    }
                    if { $arg == "-and_return" } {
                        set and_return [lindex $args $i+1]
                        incr i
                    }


                    # Raise an error, unknown option...
                } else {
                    set block $arg
                    # Raise an error if there are more arguments that have to be processed
                }
            }


            if { [info exists block] } {
                if { [llength $block] < 3 } {
                    lappend block [uplevel 1 [list namespace current]]
                }
            } else {
                set block {}
            }

            set stub [[my __mock_proxy] add_stub $method_name $block]

            if { [info exists with] } {
                $stub with $with
            }

            if { [info exists and_return] } {
                $stub and_return $and_return
            }
        }

        method unstub { method_name } {
            [my __mock_proxy] remove_stub $method_name
        }

        method as_null_object {} {
            [my __mock_proxy] as_null_object
        }

        method null_object? {} {
            [my __mock_proxy] null_object?
        }

        # @api private
        method spec_verify { } {
            [my __mock_proxy] verify
        }

        # @api private
        method spec_reset { } {
            [my __mock_proxy] reset
        }

        method __mock_proxy { } {
            my variable mock_proxy name options

            if { ![info exists mock_proxy] } {
                set mock_proxy [::Spec::Mocks::TclOO::Proxy new [self]]
            }

            return $mock_proxy
        }
    }
}
