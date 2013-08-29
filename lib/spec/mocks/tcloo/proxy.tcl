namespace eval Spec::Mocks::TclOO {
    oo::class create Proxy {
        constructor { object {name ""} {options {}} } {
            set [self]::object $object
            set [self]::name $name
            set [self]::options $options
            set [self]::method_doubles [dict create]
            set [self]::null_object false

            set [self]::error_generator [Spec::Mocks::TclOO::ErrorGenerator new -object ${object} -name ${name} -options ${options}]
        }

        method add_message_expectation { message {block {}} } {
            my variable error_generator
            [my method_double_for $message] add_expectation ${error_generator} $block
        }

        method add_negative_message_expectation { message } {
            my variable error_generator
            [my method_double_for $message] add_negative_expectation  ${error_generator}
        }

        method add_stub { method_name {implementation {}} } {
            my variable error_generator
            [my method_double_for $method_name] add_stub ${error_generator} $implementation
        }

        method remove_stub { method_name } {
            [my method_double_for $method_name] remove_stub
        }

        method null_object? {} {
            my variable null_object
            expr { ${null_object} }
        }

        method as_null_object {} {
            set [self]::null_object true
            set [self]::object
        }

        method has_negative_expectation? { method_name } {
            foreach expectation [[my method_double_for $method_name] expectations] {
                if { [$expectation negative_expectation_for? $method_name] } {
                    return true
                }
            }

            return false
        }

        method message_received { method_name args } {
            set expectation [my find_matching_expectation $method_name {*}$args]
            set stub [my __find_matching_method_stub $method_name {*}$args]

            set level [expr { [info level] - 2 }]

            if { $stub != false && ($expectation == false || [$expectation called_max_times?]) } {
                if { $expectation != false && [$expectation actual_received_count_matters?] } {
                    $expectation increase_actual_receive_count
                }

                $stub invoke $level {*}$args
            } elseif { $expectation != false } {
                $expectation invoke $level {*}$args
            } elseif { [set expectation [my __find_almost_matching_expectation $method_name {*}$args]] != false } {
                if { ![my has_negative_expectation? $method_name] && ![my null_object?] } {
                    [my raise_unexpected_message_args_error $expectation {*}$args]
                }
            }
        }

        method raise_unexpected_message_args_error { expectation args } {
            my variable error_generator
            $error_generator raise_unexpected_message_args_error $expectation {*}$args
        }

        method raise_unexpected_message_error { method_name args } {
            my variable error_generator
            $error_generator raise_unexpected_message_error $method_name {*}$args
        }

        method find_matching_expectation { method_name args } {
            [my method_double_for $method_name] find_matching_expectation {*}$args
        }

        method __find_almost_matching_expectation { method_name args } {
            [my method_double_for $method_name] find_almost_matching_expectation {*}$args
        }

        method __find_matching_method_stub { method_name args } {
            [my method_double_for $method_name] find_matching_method_stub {*}$args
        }

        method method_double_for { message } {
            my variable method_doubles object
            if { ![dict exists ${method_doubles} $message] } {
                dict set method_doubles $message [::Spec::Mocks::TclOO::MethodDouble new \
                    -object ${object} \
                    -message_name $message \
                    -proxy [self]
                ]
            }

            dict get ${method_doubles} $message
        }

        method verify {} {
            my variable method_doubles
            dict for {_ method_double} ${method_doubles} {
                $method_double verify
            }
        }

        method reset {} {
            my variable method_doubles object
            dict for {_ method_double} ${method_doubles} {
                $method_double reset
            }
        }
    }
}
