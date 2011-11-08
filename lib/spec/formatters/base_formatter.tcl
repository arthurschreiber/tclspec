namespace eval Spec {
    namespace eval Formatters {
        Class create BaseFormatter
        BaseFormatter instproc init { {output stdout} } {
            my set outpout $output

            my set example_count 0
            my set failure_count 0

            my set examples {}
            my set failed_examples {}
        }

        BaseFormatter instproc start { example_count } {
            my set example_count $example_count
        }

        BaseFormatter instproc example_group_started { example_group } {

        }

        BaseFormatter instproc example_group_finished { example_group } {

        }

        BaseFormatter instproc example_started { example } {
            my lappend examples $example
        }

        BaseFormatter instproc example_passed { example } {

        }

        BaseFormatter instproc example_failed { example } {
            my lappend failed_examples $example
        }

        BaseFormatter instproc message { message } {

        }

        BaseFormatter instproc stop { } {

        }

        BaseFormatter instproc start_dump { } {

        }

        BaseFormatter instproc dump_failures { } {

        }

        BaseFormatter instproc dump_summary { duration example_count failure_count } {
            my set duration      $duration
            my set example_count $example_count
            my set failure_count $failure_count
        }

        BaseFormatter instproc format_backtrace { $error_info $example } {
            set cleaned_error_info {}
        }
    }
}