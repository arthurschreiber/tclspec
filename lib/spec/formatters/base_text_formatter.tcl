namespace eval Spec {
    namespace eval Formatters {
        namespace eval BaseTextFormatter {
            variable VT100_COLORS [dict create \
                "black"     30 \
                "red"       31 \
                "green"     32 \
                "yellow"    33 \
                "blue"      34 \
                "magenta"   35 \
                "cyan"      36 \
                "white"     37 \
            ]
        }

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
                puts [my colorize_summary [my summary_line $example_count $failure_count]]
            }

            method summary_line { example_count failure_count } {
                set summary [my pluralize $example_count "example"]
                append summary ", [my pluralize $failure_count "failure"]"
            }

            method pluralize { count string } {
                return "$count $string[expr { $count != 1 ? "s" : "" }]"
            }

            method colorize_summary { summary } {
                my variable failure_count

                if { $failure_count > 0 } {
                    my _failure_color $summary
                } else {
                    my _success_color $summary
                }
            }


            method _success_color { text } {
                my _color $text [dict get $::Spec::Formatters::BaseTextFormatter::VT100_COLORS "green"]
            }
            
            method _failure_color { text } {
                my _color $text [dict get $::Spec::Formatters::BaseTextFormatter::VT100_COLORS "red"]
            }

            method _color { text code } {
                return "\x1B\[${code}m${text}\x1B\[0m"
            }
        }
    }
}
