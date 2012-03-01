namespace eval Spec {
    namespace eval Mocks {
        nx::Class create MethodDouble {
            :property object:required
            :property method_name:required
            :property proxy:required

            :property {expectations {}}
            :property {stubs {}}

            :variable stashed false
            :variable stashed_definition

            :public method add_expectation { error_generator {block {}} } {
                :configure_method

                if { [llength ${:stubs}] > 0 } {
                    set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:method_name} -method_block $block -return_block [[lindex ${:stubs} 0] return_block]]
                } else {
                    set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:method_name} -method_block $block]
                }

                set :expectations [concat [list $expectation] ${:expectations}]
                return $expectation
            }

            :public method add_negative_expectation { error_generator } {
                :configure_method

                set expectation [NegativeMessageExpectation new -error_generator $error_generator -method_name ${:method_name}]
                set :expectations [concat [list $expectation] ${:expectations}]
                return $expectation
            }

            :public method add_stub { error_generator {implementation {}} } {
                :configure_method

                set stub [MessageExpectation new -error_generator $error_generator -method_name ${:method_name} -return_block $implementation -expected_receive_count any]
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

            :public method configure_method { } {
                [::Spec::Mocks space] add ${:object}
                if { !${:stashed} } {
                    :stash_original_method
                    :define_proxy_method
                }
            }

            :public method stash_original_method {} {
                set :stashed true
                set :stashed_definition [:original_method_definition]
            }

            :public method verify {} {
                foreach expectation ${:expectations} {
                    $expectation verify_messages_received
                }
            }

            :public method clear {} {
                # TODO destroy all message expectations
                set :expectations [list]
                set :stubs [list]
            }

            :public method reset {} {
                :restore_original_method
                :clear
            }

            :public method original_method_definition {} {
                ${:object} info method definition ${:method_name}
            }

            :public method visibility {} {
                if { [${:object} info class] == "::Spec::Mocks::Mock" } {
                    return "public"
                } else {
                    set definition [${:object} info method definition ${:method_name}]

                    if { $definition == "" } {
                        set definition [[${:object} info class] info method definition ${:method_name}]
                    }

                    if { $definition != "" } {
                        return [lindex $definition 1]
                    } else {
                        return "public"
                    }
                }
            }

            :public method define_proxy_method {} {
                ${:object} [:visibility] method ${:method_name} { args } "
                    \[:__mock_proxy] message_received {${:method_name}} {*}\$args
                "
            }

            :public method undefine_proxy_method {} {
                ${:object} public method ${:method_name} {} {}
            }

            :public method restore_original_method {} {
                if { ${:stashed} } {
                    :undefine_proxy_method
                    eval ${:stashed_definition}
                    set :stashed false
                }
            }
        }
    }
}