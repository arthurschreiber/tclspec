nx::Class create ::Spec::Mocks::ProcDouble {
    :property proc_name:required

    :property {expectations {}}
    :property {stubs {}}

    :variable stashed false

    :public method add_expectation { error_generator {block {}} } {
        :configure_method

        if { [llength ${:stubs}] > 0 } {
            set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -method_block $block -return_block [[lindex ${:stubs} 0] return_block]]
        } else {
            set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -method_block $block]
        }

        set :expectations [concat [list $expectation] ${:expectations}]
        return $expectation
    }

    :public method add_negative_expectation { error_generator } {
        :configure_method

        set expectation [NegativeMessageExpectation new -error_generator $error_generator -method_name ${:proc_name}]
        set :expectations [concat [list $expectation] ${:expectations}]
        return $expectation
    }

    :public method add_stub { error_generator {implementation {}} } {
        :configure_method

        set stub [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -return_block $implementation]
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
        if { !${:stashed} } {
            :stash_original_method
            :define_proxy_method
        }
    }

    :public method stashed_proc_name {} {
        return "${:proc_name}_obfuscated_by_tclspec_"
    }

    :public method stash_original_method {} {
        set :stashed true

        if { [info procs ${:proc_name}] == ${:proc_name} } {
            rename ${:proc_name} [:stashed_proc_name]
        }
    }

    :public method define_proxy_method {} {
        proc ${:proc_name} { args } "
            \[::Spec::Mocks::TclDoubler new] message_received {${:proc_name}} {*}\$args
        "
    }

    :public method restore_original_method {} {
        if { ${:stashed} } {
            rename ${:proc_name} {}

            if { [info procs [:stashed_proc_name]] == [:stashed_proc_name] } {
                rename [:stashed_proc_name] ${:proc_name}
            }

            set :stashed false
        }
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
}