namespace eval Spec {
    namespace eval Formatters {
        namespace path ::Spec
    }
}

source [file join [file dirname [info script]] "formatters/base_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/base_text_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/documentation_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/progress_formatter.tcl"]

namespace eval Spec {
    Class create Reporter
    Reporter instproc init { formatters } {
        my set formatters $formatters

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