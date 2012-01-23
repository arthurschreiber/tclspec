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

            :public method add_expectation { {block {}} } {
                :configure_method
                set expectation [MessageExpectation new -method_name ${:method_name} -method_block $block]
                lappend :expectations $expectation
                return $expectation
            }

            :public method add_negative_expectation { } {
                :configure_method
                set expectation [NegativeMessageExpectation new -method_name ${:method_name}]
                lappend :expectations $expectation
                return $expectation
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

                puts "[${:object} info method definition ${:method_name}]"
            }

            :public method undefine_proxy_method {} {
                ${:object} public method ${:method_name} {} {}
            }

            :public method restore_original_method {} {
                if { ${:stashed} } {
                    :undefine_proxy_method
                    eval ${:stashed_definition}
                }
            }
        }
    }
}