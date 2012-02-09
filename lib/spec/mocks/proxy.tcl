namespace eval Spec {
    namespace eval Mocks {
        nx::Class create Proxy {
            :property object:required
            :property {name ""}

            :property [list method_doubles [dict create]]

            :public method add_message_expectation { message {block {}} } {
                [:method_double_for $message] add_expectation $block
            }

            :public method add_negative_message_expectation { message } {
                [:method_double_for $message] add_negative_expectation
            }

            :public method message_received { method_name args } {
                set expectation [:find_matching_expectation $method_name {*}$args]
                if { $expectation != false } {
                    $expectation invoke {*}$args
                }
            }

            :public method find_matching_expectation { method_name args } {
                foreach expectation [[:method_double_for $method_name] expectations] {
                    if { [$expectation matches? $method_name {*}$args] } {
                        return $expectation
                    }
                }

                return false
            }

            :private method find_matching_stub_method { method_name args } {
                foreach stub [[:method_double_for $method_name] stubs] {
                    if { [$stub matches? $method_name {*}$args] } {
                        return $stub
                    }
                }

                return false
            }

            :public method method_double_for { message } {
                if { ![dict exists ${:method_doubles} $message] } {
                    dict set :method_doubles $message [MethodDouble new \
                        -object ${:object} \
                        -method_name $message \
                        -proxy [:]
                    ]
                }

                dict get ${:method_doubles} $message
            }

            :public method verify {} {
                dict for {_ method_double} ${:method_doubles} {
                    $method_double verify
                }
            }

            :public method reset {} {
                
            }
        }
    }
}