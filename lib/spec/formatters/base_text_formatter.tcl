namespace eval Spec {
    namespace eval Formatters {
        nx::Class create BaseTextFormatter -superclass BaseFormatter {
            :public method message { message } {
                puts $message
            }

           :public method dump_failures { } {
                if { [llength ${:failed_examples}] > 0 } {
                    puts ""
                    puts "Failures:"

                    set index 0
                    foreach example ${:failed_examples} {
                        puts ""
                        :dump_failure $example $index
                        :dump_backtrace $example

                        incr index
                    }
                }
            }

            :public method dump_failure { example index } {
                puts "  [expr {$index + 1}]) [$example full_description]"
            }

            :public method dump_backtrace { example } {
                foreach line [split [$example error_info] "\n"] {
                    puts "     $line"
                }
            }

            :public method dump_summary { duration example_count failure_count } {
                next

                puts ""
                puts "Finished in $duration milliseconds"
                puts ""
                puts [:summary_line $example_count $failure_count]
            }

            :public method summary_line { example_count failure_count } {
                set summary [:pluralize $example_count "example"]
                append summary ", [:pluralize $failure_count "failure"]"
            }

            :public method pluralize { count string } {
                return "$count $string[expr { $count != 1 ? "s" : "" }]"
            }
        }
    }
}