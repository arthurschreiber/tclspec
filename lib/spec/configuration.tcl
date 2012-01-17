namespace eval Spec {
    nx::Class create Configuration {
        :property {formatters [list]}

        :variable reporter

        :public method add_formatter { name } {
            if { $name == "doc" } {
                lappend :formatters [::Spec::Formatters::DocumentationFormatter new]
            } elseif { $name == "progress" } {
                lappend :formatters [::Spec::Formatters::ProgressFormatter new]
            }
        }

        :public method reporter { } {
            if { ![info exists :reporter] } {
                if { [llength ${:formatters}] == 0 } {
                    :add_formatter "progress"
                }

                set :reporter [::Spec::Reporter new -formatters ${:formatters}]
            }

            return ${:reporter}
        }
    }
}