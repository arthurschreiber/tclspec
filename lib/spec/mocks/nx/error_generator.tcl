namespace eval Spec {
    namespace eval Mocks {
        nx::Class create ErrorGenerator {
            :property object:required
            :property {name ""}
            :property {options {}}

            :public method init {} {
                if { [dict exists ${:options} __declared_as] } {
                    set :declared_as [dict get ${:options} __declared_as]
                } else {
                    set :declared_as "Mock"
                }
            }

            :public method raise_expectation_error { method expected_received_count actual_received_count args } {
                set message "([:intro]).${method}[:format_args {*}${args}]"
                append message "\n    expected: [:count_message ${expected_received_count}]"
                append message "\n    received: [:count_message ${actual_received_count}]"

                :__raise $message
            }

            :public method raise_unexpected_message_error { method_name args } {
                set message "[:intro] received unexpected message: $method_name with [:format_args {*}$args]"

                :__raise $message
            }

            :public method raise_unexpected_message_args_error { expectation args } {
                if { "expected_args" in [$expectation info vars] } {
                    set expected_args [:format_args {*}[$expectation expected_args]]
                } else {
                    set expected_args "(no args)"
                }
                set actual_args [:format_args {*}$args]

                set message "[:intro] received [$expectation method_name] with unexpected arguments"
                append message "\n  expected: $expected_args"
                append message "\n       got: $actual_args"

                :__raise $message
            }

            :protected method __raise { message } {
                return -code error -errorcode ::Spec::Mocks::ExpectationError $message
            }

            :protected method intro {} {
                if { ${:name} != "" } {
                    return "${:declared_as} \"${:name}\""
                } elseif { [${:object} info class] == "::Spec::Mocks::Mock" } {
                    return ${:declared_as}
                } else {
                    return ${:object}
                }
            }

            :protected method count_message { count } {
                :pretty_print $count
            }

            :protected method pretty_print { count } {
                return "$count time[expr { $count == 1 ? "" : "s" }]"
            }

            :protected method arg_list { args } {
                set result [list]
                foreach arg $args {
                    if { [::nsf::is object $arg] && "description" in [$arg info lookup methods] } {
                        lappend result [$arg description]
                    } else {
                        lappend result $arg
                    }
                }
                join $result " "
            }

            :protected method format_args { args } {
                if { [llength $args] == 0 } {
                    return "(no args)"
                } else {
                    return "([:arg_list $args])"
                }
            }
        }
    }
}