namespace eval ::Spec::Mocks::Tcl {
    nx::Class create ProcDouble -superclass Abstract::MessageDouble {

        :variable stashed false
        :variable real_message_name

        :protected method init {} {
            switch [llength ${:message_name}] {
                1 {
                    # It's a normal tcl proc name, we don't have
                    # to do anything
                    set :real_message_name ${:message_name}
                }
                2 {
                    # Looks like an ensemble method. We have to figure out the
                    # actual message name now.
                    set ensemble_options [namespace ensemble configure [lindex ${:message_name} 0]]
                    set namespace [dict get $ensemble_options -namespace]
                    set :real_message_name "${namespace}::[lindex ${:message_name} 1]"
                }
                default {
                    # This should never happen.
                    # TODO: Throw an error here.
                }
            }
        }

        :public method configure_message { } {
            if { !${:stashed} } {
                :stash_original_method
                :define_proxy_method
            }
        }

        :public method stashed_proc_name {} {
            return "${:real_message_name}_obfuscated_by_tclspec_"
        }

        :public method stash_original_method {} {
            set :stashed true

            if { [info commands ${:real_message_name}] == ${:real_message_name} } {
                rename ${:real_message_name} [:stashed_proc_name]
            }
        }

        :public method define_proxy_method {} {
            proc ${:real_message_name} { args } "
                \[::Spec::Mocks::Tcl::Doubler new] message_received {${:message_name}} {*}\$args
            "
        }

        :public method restore_original_method {} {
            if { ${:stashed} } {
                rename ${:real_message_name} {}

                if { [info commands [:stashed_proc_name]] == [:stashed_proc_name] } {
                    rename [:stashed_proc_name] ${:real_message_name}
                }

                set :stashed false
            }
        }

        :public method reset {} {
            :restore_original_method
            next
        }
    }
}