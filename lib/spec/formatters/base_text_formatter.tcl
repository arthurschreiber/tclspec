namespace eval Spec {
    namespace eval Formatters {
        oo::class create BaseTextFormatter {
            superclass ::Spec::Formatters::BaseFormatter

            method message { message } {
                puts $message
            }

           method dump_failures { } {
                if { [llength [set [self]::failed_examples]] > 0 } {
                    puts ""
                    puts "Failures:"

                    set index 0
                    foreach example [set [self]::failed_examples] {
                        puts ""
                        my dump_failure $example $index
                        my dump_backtrace $example

                        incr index
                    }
                }
            }

            method dump_failure { example index } {
                puts "  [expr {$index + 1}]) [$example full_description]"
            }

            method dump_backtrace { example } {
                foreach line [split [$example error_info] "\n"] {
                    puts "     $line"
                }
            }

            method dump_summary { duration example_count failure_count } {
                next $duration $example_count $failure_count

                puts ""
                puts "Finished in $duration milliseconds"
                puts ""
                puts [my summary_line $example_count $failure_count]
            }

            method summary_line { example_count failure_count } {
                set summary [my pluralize $example_count "example"]
                append summary ", [my pluralize $failure_count "failure"]"
            }

            method pluralize { count string } {
                return "$count $string[expr { $count != 1 ? "s" : "" }]"
            }
        }
    }
}
