namespace eval ::Spec::Mocks::Abstract {
    namespace path ::Spec::Mocks

    nx::Class create MessageDouble {
        :property message_name:required

        :property {expectations {}}
        :property {stubs {}}

        :public method add_expectation { error_generator {block {}} } {
            :configure_message

            if { [llength ${:stubs}] > 0 } {
                set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:message_name} -method_block $block -return_block [[lindex ${:stubs} 0] return_block]]
            } else {
                set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:message_name} -method_block $block]
            }

            set :expectations [concat [list $expectation] ${:expectations}]
            return $expectation
        }

        :public method add_negative_expectation { error_generator } {
            :configure_message

            set expectation [NegativeMessageExpectation new -error_generator $error_generator -method_name ${:message_name}]
            set :expectations [concat [list $expectation] ${:expectations}]
            return $expectation
        }

        :public method add_stub { error_generator {implementation {}} } {
            :configure_message

            set stub [MessageExpectation new -error_generator $error_generator -method_name ${:message_name} -return_block $implementation -expected_receive_count any]
            set :stubs [concat [list $stub] ${:stubs}]
            return $stub
        }

        :public method remove_stub {} {
            set :stubs [list]
        }

        :public method find_matching_expectation { args } {
            foreach expectation ${:expectations} {
                if { [$expectation matches_args? {*}$args] } {
                    if { ![$expectation called_max_times?] } {
                        return $expectation
                    }
                }
            }

            foreach expectation ${:expectations} {
                if { [$expectation matches_args? {*}$args] } {
                    return $expectation
                }
            }

            return false
        }

        :public method find_almost_matching_expectation { args } {
            foreach expectation ${:expectations} {
                if { ![$expectation matches_args? {*}$args] } {
                    if { ![$expectation called_max_times?] } {
                        return $expectation
                    }
                }
            }

            return false
        }

        :public method find_matching_method_stub { args } {
            foreach stub ${:stubs} {
                if { [$stub matches_args? {*}$args] } {
                    return $stub
                }
            }

            return false
        }

        # @abstract
        :public method configure_message { } { }

        :public method clear {} {
            # TODO destroy all message expectations
            set :expectations [list]
            set :stubs [list]
        }


        :public method verify {} {
            foreach expectation ${:expectations} {
                $expectation verify_messages_received
            }
        }

        # @overwrite
        :public method reset {} {
            :clear
        }
    }
}