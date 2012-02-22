namespace eval Spec {
    namespace eval Mocks {
        nx::Class create ErrorGenerator {
            :property object:required
            :property {name ""}
            :property {declared_as "Mock"}

            :public method raise_expectation_error { method expected_received_count actual_received_count args } {
                set message "([:intro]).${method}[:format_args {*}${args}]"
                append message "\n    expected: [:count_message ${expected_received_count}]"
                append message "\n    received: [:count_message ${actual_received_count}]"
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

            :protected method format_args { args } {
                if { [llength $args] == 0 } {
                    return "(no args)"
                } else {
                    return "([join $args " "])"
                }
            }
        }
    }
}