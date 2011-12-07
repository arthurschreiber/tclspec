namespace eval Spec {
    namespace eval Formatters {
        Class create DocumentationFormatter -superclass BaseTextFormatter
        DocumentationFormatter instproc init {} {
            next

            my set group_level 0
            my set failure_index 0
        }

        DocumentationFormatter instproc example_group_started { example_group } {
            next

            if { [my set group_level] == 0 } {
                puts ""
            }
            puts "[my current_indentation][$example_group set description]"

            my incr group_level
        }

        DocumentationFormatter instproc example_group_finished { example_group } {
            next

            my incr group_level -1
        }

        DocumentationFormatter instproc example_passed { example } {
            next

            puts [my passed_output $example]
        }

        DocumentationFormatter instproc example_failed { example } {
            next

            puts [my failure_output $example]
        }

        DocumentationFormatter instproc passed_output { example } {
            return "[my current_indentation][$example set description]"
        }

        DocumentationFormatter instproc failure_output { example } {
            return "[my current_indentation][$example set description] (FAILED - [my next_failure_index])"
        }

        DocumentationFormatter instproc next_failure_index {} {
            my incr failure_index
        }

        DocumentationFormatter instproc current_indentation {} {
            string repeat "  " [my set group_level]
        }


    }
}