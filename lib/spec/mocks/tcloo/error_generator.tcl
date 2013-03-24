namespace eval Spec::Mocks::TclOO {
    nx::Class create ErrorGenerator -superclass Abstract::ErrorGenerator {
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
            set expected_args [:format_args {*}[$expectation expected_args]]
            set actual_args [:format_args {*}$args]

            set message "[:intro] received [$expectation method_name] with unexpected arguments"
            append message "\n  expected: $expected_args"
            append message "\n       got: $actual_args"

            :__raise $message
        }

        :protected method intro {} {
            if { ${:name} != "" } {
                return "${:declared_as} \"${:name}\""
            } else {
                return ${:object}
            }
        }
    }
}
