namespace eval ::Spec::Mocks::Tcl {
    nx::Class create ProcDouble -superclass Abstract::MessageDouble {

        :variable stashed false

        :public method configure_message { } {
            if { !${:stashed} } {
                :stash_original_method
                :define_proxy_method
            }
        }

        :public method stashed_proc_name {} {
            return "${:message_name}_obfuscated_by_tclspec_"
        }

        :public method stash_original_method {} {
            set :stashed true

            if { [info procs ${:message_name}] == ${:message_name} } {
                rename ${:message_name} [:stashed_proc_name]
            }
        }

        :public method define_proxy_method {} {
            proc ${:message_name} { args } "
                \[::Spec::Mocks::Tcl::Doubler new] message_received {${:message_name}} {*}\$args
            "
        }

        :public method restore_original_method {} {
            if { ${:stashed} } {
                rename ${:message_name} {}

                if { [info procs [:stashed_proc_name]] == [:stashed_proc_name] } {
                    rename [:stashed_proc_name] ${:message_name}
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