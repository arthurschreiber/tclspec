namespace eval Spec {
    namespace eval Mocks {
        nx::Class create MessageExpectation {
            :property method_name:required
            :property method_block
            :property {expected_receive_count 1}
            :property error_generator:required

            :variable at_least false
            :variable at_most false
            :variable exactly false

            :variable actual_receive_count 0
            :variable consecutive false

            :public method matches_args? { args } {
                if { [info exists :expected_args] } {
                    expr { $args == ${:expected_args} }
                } else {
                    return true
                }
            }

            :public method negative_expectation_for? { name } {
                return false
            }

            :public method has_method_block? {} {
                expr { [info exists :method_block] && ${:method_block} != {} }
            }

            :public method called_max_times? {} {
                expr { ${:expected_receive_count} > 0 && ${:actual_receive_count} >= ${:expected_receive_count} }
            }

            :public method verify_messages_received {} {
                if { ![:expected_messages_received?] } {
                    :generate_error
                }
            }

            :public method once {} {
                set :expected_receive_count 1
            }

            :public method twice {} {
                set :expected_receive_count 2
            }

            :public method never {} {
                set :expected_receive_count 0
            }

            :public method with { arguments } {
                set :expected_args $arguments
            }

            :public method actual_received_count_matters? {} {
                expr { ${:at_least} || ${:at_most} || ${:exactly} }
            }

            :public method and_return { values } {
                if { ${:method_block} != {} } {
                    error "AmbigousReturnError"
                }

                switch { [llength $values] } {
                    0 {
                        set value {}
                    }
                    1 {
                        set value [lindex $values 0]
                    }
                    default {
                        set :consecutive true
                        if { ${:expected_receive_count} < [llength $values] } {
                            set :expected_receive_count [llength $values]
                        }
                        set value $values
                    }
                }

                set :method_block [list [list] [list return $value]]
            }

            :public method generate_error {} {
                ${:error_generator} raise_expectation_error ${:method_name} \
                    ${:expected_receive_count} ${:actual_receive_count} \
                    {*}[expr { [info exists :expected_args] ? ${:expected_args} : {}}]
            }

            :public method expected_messages_received? {} {
                expr { [:matches_exact_count?] }
            }

            :public method matches_exact_count? {} {
                expr { ${:expected_receive_count} == ${:actual_receive_count}}
            }

            :public method increase_actual_receive_count {} {
                incr :actual_receive_count
            }

            :public method invoke { args } {
                if { ${:expected_receive_count} == 0 } {
                    :increase_actual_receive_count
                    return -code error -errorcode ::Spec::Mocks::ExpectationError "Expected ${:method_name} not to be called"
                }

                set result ""
                if { [:has_method_block?] } {
                    if { ${:consecutive} } {
                        set result [:invoke_consecutive_method_block {*}$args]
                    } else {
                        set result [:invoke_method_block {*}$args]
                    }
                }

                :increase_actual_receive_count
                return $result
            }

            :protected method invoke_method_block { args } {
                apply ${:method_block} {*}$args
            }

            :protected method invoke_consecutive_method_block { args } {
                set value [:invoke_method_block {*}$args]
                set index [tcl::mathfunc::min ${:actual_receive_count} [expr { [llength $value] - 1 }]]
                return [lindex $value $index]
            }
        }

        nx::Class create NegativeMessageExpectation -superclass MessageExpectation {
            :public method init {} {
                set :expected_receive_count 0
            }

            :public method negative_expectation_for? { name } {
                expr { $name == ${:method_name}}
            }
        }
    }
}
