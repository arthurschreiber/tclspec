namespace eval Spec {
    namespace eval Formatters {
        oo::class create DocumentationFormatter {
            superclass ::Spec::Formatters::BaseTextFormatter

            constructor {} {
                set [self]::group_level 0
                set [self]::failure_index 0

                next
            }

            method example_group_started { example_group } {
                next $example_group

                if { [set [self]::group_level] == 0 } {
                    puts ""
                }
                puts "[my current_indentation][$example_group description]"

                incr [self]::group_level
            }

            method example_group_finished { example_group } {
                next $example_group

                incr [self]::group_level -1
            }

            method example_passed { example } {
                next $example

                puts [my passed_output $example]
            }

            method example_pending { example } {
                next $example

                puts [my pending_output $example]
            }

            method example_failed { example } {
                next $example

                puts [my failure_output $example]
            }

            method passed_output { example } {
                return "[my current_indentation][$example description]"
            }

            method pending_output { example } {
                return "[my current_indentation][$example description] (PENDING)"
            }

            method failure_output { example } {
                return "[my current_indentation][$example description] (FAILED - [my next_failure_index])"
            }

            method next_failure_index {} {
                incr [self]::failure_index
            }

            method current_indentation {} {
                string repeat "  " [set [self]::group_level]
            }
        }

    }
}
