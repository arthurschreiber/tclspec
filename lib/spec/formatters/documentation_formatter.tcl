namespace eval Spec {
    namespace eval Formatters {
        nx::Class create DocumentationFormatter -superclass BaseTextFormatter {
            :property {group_level 0}
            :property {failure_index 0}

            :public method example_group_started { example_group } {
                next

                if { ${:group_level} == 0 } {
                    puts ""
                }
                puts "[:current_indentation][$example_group description]"

                incr :group_level
            }

            :public method example_group_finished { example_group } {
                next

                incr :group_level -1
            }

            :public method example_passed { example } {
                next

                puts [:passed_output $example]
            }

            :public method example_failed { example } {
                next

                puts [:failure_output $example]
            }

            :public method passed_output { example } {
                return "[:current_indentation][$example description]"
            }

            :public method failure_output { example } {
                return "[:current_indentation][$example description] (FAILED - [:next_failure_index])"
            }

            :public method next_failure_index {} {
                incr :failure_index
            }

            :public method current_indentation {} {
                string repeat "  " ${:group_level}
            }
        }

    }
}