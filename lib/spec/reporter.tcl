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
    oo::class create Reporter {
        constructor { formatters } {
            set [self]::formatters $formatters
            set [self]::example_count 0
            set [self]::failure_count 0
            set [self]::start 0
            set [self]::duration 0
        }

        method formatters {} {
            set [self]::formatters
        }

        method report { expected_example_count block } {
            my start $expected_example_count

            # yield self?
            uplevel $block

            my finish
        }

        method start { expected_example_count } {
            set [self]::start [clock clicks -milliseconds]
            my notify start $expected_example_count
        }

        method message { message } {
            my notify message $message
        }

        method example_group_started { example_group } {
            my notify example_group_started $example_group
        }

        method example_group_finished { example_group } {
            my notify example_group_finished $example_group
        }

        method example_started { example } {
            incr [self]::example_count
            my notify example_started $example
        }

        method example_passed { example } {
            my notify example_passed $example
        }

        method example_failed { example } {
            incr [self]::failure_count
            my notify example_failed $example
        }

        method finish {} {
            my stop

            my notify start_dump
            my notify dump_failures
            my notify dump_summary [set [self]::duration] [set [self]::example_count] [set [self]::failure_count]
        }

        method stop {} {
            set [self]::duration [ expr { [clock clicks -milliseconds] - [set [self]::start] } ]
            my notify stop
        }

        method notify { method args } {
            foreach formatter [set [self]::formatters] {
                $formatter $method {*}$args
            }
        }
    }
}
