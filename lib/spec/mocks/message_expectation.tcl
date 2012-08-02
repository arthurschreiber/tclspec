namespace eval Spec {
    namespace eval Mocks {
        nx::Class create MessageExpectation {
            :property method_name:required

            :property method_block
            :property return_block

            :property {expected_receive_count 1}
            :property error_generator:required

            :variable at_least false
            :variable at_most false
            :variable exactly false

            :variable argument_expectation

            :variable actual_receive_count 0
            :variable consecutive false

            :public method init {} {
                set :argument_expectation [
                    ArgumentExpectation new -args [AnyArgsMatcher new]
                ]
            }

            :public method matches_args? { args } {
                ${:argument_expectation} args_match? {*}$args
            }

            :public method negative_expectation_for? { name } {
                return false
            }

            :public method has_method_block? {} {
                expr { [info exists :method_block] && ${:method_block} != {} }
            }

            :public method has_return_block? {} {
                expr { [info exists :return_block] && ${:return_block} != {} }
            }

            :public method called_max_times? {} {
                expr { ![:ignoring_receive_count?] && ${:expected_receive_count} > 0 &&
                    ${:actual_receive_count} >= ${:expected_receive_count} }
            }

            :public method verify_messages_received {} {
                if { ![:expected_messages_received?] } {
                    :generate_error
                }
            }

            :public method expected_args {} {
                ${:argument_expectation} args
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

            :public method exactly { times } {
                :set_expected_received_count "exactly" $times
            }

            :public method at_least { times } {
                :set_expected_received_count "at_least" $times
            }

            :public method at_most { times } {
                :set_expected_received_count "at_most" $times
            }

            :protected method set_expected_received_count { relativity times } {
                set :at_least [expr { $relativity == "at_least" }]
                set :at_most [expr { $relativity == "at_most" }]
                set :exactly [expr { $relativity == "exactly" }]

                set :at_most true
                if { $times == "once" } {
                    set times 1
                } elseif { $times == "twice" } {
                    set times 2
                } elseif { ![regexp {^(\d+)(\.time(s)?)?$} $times -> times] } {
                    error "wtf $times"
                }
                set :expected_receive_count $times
            }

            :public method any_number_of_times {} {
                set :expected_receive_count any
            }

            :public method with { arguments } {
                set :argument_expectation [ArgumentExpectation new -args $arguments]
            }

            :public method actual_received_count_matters? {} {
                expr { ${:at_least} || ${:at_most} || ${:exactly} }
            }

            :public method and_return { values } {
                if { [:has_method_block?] && ${:method_block} != {} } {
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
                        if { ![:ignoring_receive_count?] && ${:expected_receive_count} < [llength $values] } {
                            set :expected_receive_count [llength $values]
                        }
                        set value $values
                    }
                }

                set :return_block [list [list args] [list return $value]]
            }

            :public method generate_error {} {
                ${:error_generator} raise_expectation_error ${:method_name} \
                    ${:expected_receive_count} ${:actual_receive_count} \
                    {*}[:expected_args]
            }

            :public method expected_messages_received? {} {
                expr { [:ignoring_receive_count?] || [:matches_exact_count?] || [:matches_at_least_count?] || [:matches_at_most_count?] }
            }

            :public method ignoring_receive_count? {} {
                expr { ${:expected_receive_count} == "any" }
            }

            :public method matches_at_least_count? {} {
                expr { ${:at_least} && ${:actual_receive_count} >= ${:expected_receive_count} }
            }

            :public method matches_at_most_count? {} {
                expr { ${:at_most} && ${:actual_receive_count} <= ${:expected_receive_count} }
            }

            :public method matches_exact_count? {} {
                expr { ${:expected_receive_count} == ${:actual_receive_count}}
            }

            :public method increase_actual_receive_count {} {
                incr :actual_receive_count
            }

            :public method invoke { level args } {
                if { ${:expected_receive_count} == 0 } {
                    :increase_actual_receive_count
                    ${:error_generator} raise_expectation_error ${:method_name} ${:expected_receive_count} ${:actual_receive_count} {*}$args
                }

                set result ""
                if { [:has_method_block?] } {
                    set result [:invoke_method_block $level {*}$args]
                } elseif { [:has_return_block?] } {
                    if { ${:consecutive} } {
                        set result [:invoke_consecutive_return_block $level {*}$args]
                    } else {
                        set result [:invoke_return_block $level {*}$args]
                    }
                }

                :increase_actual_receive_count
                return $result
            }

            :protected method invoke_method_block { level args } {
                uplevel "#$level" [list apply ${:method_block} {*}$args]
            }

            :protected method invoke_return_block { level args } {
                uplevel "#$level" [list apply ${:return_block} {*}$args]
            }

            :protected method invoke_consecutive_return_block { level args } {
                set value [:invoke_return_block $level {*}$args]
                set index [tcl::mathfunc::min ${:actual_receive_count} [expr { [llength $value] - 1 }]]
                return [lindex $value $index]
            }
        }

        nx::Class create NegativeMessageExpectation -superclass MessageExpectation {
            :property {expected_receive_count 0}

            :public method negative_expectation_for? { name } {
                expr { $name == ${:method_name}}
            }
        }
    }
}
