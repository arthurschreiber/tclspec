namespace eval Spec {
    namespace eval Formatters {
        Class create BaseTextFormatter -superclass BaseFormatter

        BaseTextFormatter instproc message { message } {
            puts $message
        }

        BaseTextFormatter instproc dump_failures { } {
            if { [llength [my set failed_examples]] > 0 } {
                puts ""
                puts "Failures:"

                set index 0
                foreach example [my set failed_examples] {
                    puts ""
                    my dump_failure $example $index
                    my dump_backtrace $example

                    incr index
                }
            }
        }

        BaseTextFormatter instproc dump_failure { example index } {
            puts "  [expr {$index + 1}]) [$example full_description]"
        }

        BaseTextFormatter instproc dump_backtrace { example } {
            foreach line [split [$example error_info] "\n"] {
                puts "     $line"
            }
        }

        BaseTextFormatter instproc dump_summary { duration example_count failure_count } {
            next

            puts ""
            puts "Finished in $duration milliseconds"
            puts ""
            puts [my summary_line $example_count $failure_count]
        }

        BaseTextFormatter instproc summary_line { example_count failure_count } {
            set summary [my pluralize $example_count "example"]
            append summary ", [my pluralize $failure_count "failure"]"

            set summary
        }

        BaseTextFormatter instproc pluralize { count string } {
            return "$count $string[expr { $count != 1 ? "s" : "" }]"
        }
    }
}