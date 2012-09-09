namespace eval Spec::Mocks::nx {
    nx::Class create MethodDouble -superclass Abstract::MessageDouble {
        :property object:required
        :property proxy:required

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
            set :stashed true
            set :stashed_definition [:original_method_definition]
        }

        :public method reset {} {
            :restore_original_method
            next
        }

        :public method original_method_definition {} {
            ${:object} info method definition ${:message_name}
        }

        :public method visibility {} {
            if { [${:object} info class] == "::Spec::Mocks::nx::Mock" } {
                return "public"
            } else {
                set definition [${:object} info method definition ${:message_name}]

                if { $definition == "" } {
                    set definition [[${:object} info class] info method definition ${:message_name}]
                }

                if { $definition != "" } {
                    return "[lindex $definition 1][expr {[${:object} info class] == "::nx::Class" ? " class" : ""}]"
                } else {
                    return "public[expr {[${:object} info class] == "::nx::Class" ? " class" : ""}]"
                }
            }
        }

        :public method define_proxy_method {} {
            ${:object} {*}[:visibility] method ${:message_name} { args } "
                \[:__mock_proxy] message_received {${:message_name}} {*}\$args
            "
        }

        :public method undefine_proxy_method {} {
            ${:object} {*}[:visibility] method ${:message_name} {} {}
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
