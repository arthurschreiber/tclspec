namespace eval Spec::Mocks::TclOO {
    nx::Class create MethodDouble -superclass Abstract::MessageDouble {
        :property object:required
        :property proxy:required

        :variable proxied false
        :variable stashed false
        :variable stashed_definition

        :public method configure_message { } {
            [::Spec::Mocks space] add ${:object}
            if { !${:stashed} } {
                :stash_original_method
                :define_proxy_method
            }
        }

        :public method stash_original_method {} {
            if { ${:stashed} || ${:message_name} ni [info object methods ${:object}] } {
                return 
            }

            set :stashed true
            set :stashed_definition [:original_method_definition]
        }

        :public method reset {} {
            :restore_original_method
            next
        }

        :public method original_method_definition {} {
            info object definition ${:object} ${:message_name}
        }

        :public method define_proxy_method {} {
            set :proxied true

            oo::objdefine ${:object} method ${:message_name} { args } "
                \[my __mock_proxy] message_received {${:message_name}} {*}\$args
            "
        }

        :public method restore_original_method {} {
            if { ${:proxied} } {
                if { ${:stashed} } {
                    oo::objdefine ${:object} method ${:message_name} {*}${:stashed_definition}
                    set :stashed false
                } else {
                    oo::objdefine ${:object} deletemethod ${:message_name}
                }
            }
            
            set :proxied false
        }
    }
}
