namespace eval Spec {
    namespace eval Formatters {
        nx::Class create BaseFormatter {
            :property {output stdout}

            :property {example_count 0}
            :property {failure_count 0}

            :property {duration 0}

            :property {examples [list]}
            :property {failed_examples [list]}

            :public method start { example_count } {
                set :example_count $example_count
            }

            :public method example_group_started { example_group } {
                
            }

            :public method example_group_finished { example_group } {

            }

            :public method example_started { example } {
                lappend :examples $example
            }

            :public method example_passed { example } {

            }

            :public method example_failed { example } {
                lappend :failed_examples $example
            }

            :public method message { message } {

            }

            :public method stop { } {

            }

            :public method start_dump { } {

            }

            :public method dump_failures { } {

            }

            :public method dump_summary { duration example_count failure_count } {
                set :duration      $duration
                set :example_count $example_count
                set :failure_count $failure_count
            }

            :public method format_backtrace { $error_info $example } {

            }

        }
    }
}