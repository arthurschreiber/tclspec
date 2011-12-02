namespace eval Spec {
    Class create Configuration
    Configuration instproc init {} {

    }

    Configuration instproc formatters {} {
        if { ![my exists formatters] } {
            my set formatters {}
        }

        my set formatters
    }

    Configuration instproc add_formatter { name } {
        if { $name == "doc" } {
            my lappend formatters [::Spec::Formatters::DocumentationFormatter new]
        } elseif { $name == "progress" } {
            my lappend formatters [::Spec::Formatters::ProgressFormatter new]
        }
    }

    Configuration instproc reporter { } {
        if { ![my exists reporter] } {
            if { [llength [my formatters]] == 0 } {
                my add_formatter "progress"
            }

            my set reporter [::Spec::Reporter new [my formatters]]
        }

        my set reporter
    }
}