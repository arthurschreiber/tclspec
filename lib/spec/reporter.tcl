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
    nx::Class create Reporter {
        :property formatters
        :variable example_count 0
        :variable failure_count 0
        :variable start 0
        :variable duration 0

        :public method report { expected_example_count block } {
            :start $expected_example_count

            # yield self?
            uplevel $block

            :finish
        }

        :public method start { expected_example_count } {
            set :start [clock clicks -milliseconds]
            :notify start $expected_example_count
        }

        :public method message { message } {
            :notify message $message
        }

        :public method example_group_started { example_group } {
            :notify example_group_started $example_group
        }

        :public method example_group_finished { example_group } {
            :notify example_group_finished $example_group
        }

        :public method example_started { example } {
            incr :example_count
            :notify example_started $example
        }

        :public method example_passed { example } {
            :notify example_passed $example
        }

        :public method example_failed { example } {
            incr failure_count
            :notify example_failed $example
        }

        :public method finish {} {
            :stop

            :notify start_dump
            :notify dump_failures
            :notify dump_summary ${:duration} ${:example_count} ${:failure_count}
        }

        :public method stop {} {
            set :duration [ expr { [clock clicks -milliseconds] - ${:start} } ]
            :notify stop
        }

        :public method notify { method args } {
            foreach formatter ${:formatters} {
                $formatter $method {*}$args
            }
        }
    }
}