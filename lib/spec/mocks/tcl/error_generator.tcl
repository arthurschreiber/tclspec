namespace eval ::Spec::Mocks::Tcl {
    nx::Class create ErrorGenerator -superclass Abstract::ErrorGenerator {
        :property {options {}}

        :public method raise_expectation_error { method expected_received_count actual_received_count args } {
            set message "${method}[:format_args {*}${args}]"
            append message "\n    expected: [:count_message ${expected_received_count}]"
            append message "\n    received: [:count_message ${actual_received_count}]"

            :__raise $message
        }

        :public method raise_unexpected_message_error { method_name args } {
            set message "Received unexpected call to: $method_name with [:format_args {*}$args]"

            :__raise $message
        }

        :public method raise_unexpected_message_args_error { expectation args } {
            set expected_args [:format_args {*}[$expectation expected_args]]
            set actual_args [:format_args {*}$args]

            set message "Received call to [$expectation method_name] with unexpected arguments"
            append message "\n  expected: $expected_args"
            append message "\n       got: $actual_args"

            :__raise $message
        }
    }
}
