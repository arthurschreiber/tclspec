package require XOTcl
namespace import xotcl::*

namespace eval Spec {
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
        foreach line [split [$example set error_info] "\n"] {
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

    Class create Reporter
    Reporter instproc init { } {
        my lappend formatters [BaseTextFormatter new]

        my set example_count 0
        my set failure_count 0

        my set start 0
        my set duration 0
    }

    Reporter instproc report { expected_example_count block } {
        my start $expected_example_count

        # yield self?
        uplevel $block

        my finish
    }

    Reporter instproc start { expected_example_count } {
        my set start [clock clicks -milliseconds]
        my notify start $expected_example_count
    }

    Reporter instproc message { message } {
        my notify message $message
    }

    Reporter instproc example_group_started { example_group } {
        my notify example_group_started $example_group
    }

    Reporter instproc example_group_finished { example_group } {
        my notify example_group_finished $example_group
    }

    Reporter instproc example_started { example } {
        my incr example_count
        my notify example_started $example
    }

    Reporter instproc example_passed { example } {
        my notify example_passed $example
    }

    Reporter instproc example_failed { example } {
        my incr failure_count
        my notify example_failed $example
    }

    Reporter instproc finish {} {
        my stop

        my notify start_dump
        my notify dump_failures
        my notify dump_summary [my set duration] [my set example_count] [my set failure_count]
    }

    Reporter instproc stop {} {
        my set duration [ expr { [clock clicks -milliseconds] - [my set start] } ]
        my notify stop
    }

    Reporter instproc notify { method args } {
        foreach formatter [my set formatters] {
            $formatter $method {*}$args
        }
    }
}