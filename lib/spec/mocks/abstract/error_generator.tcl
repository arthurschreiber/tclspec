namespace eval ::Spec::Mocks::Abstract {
    nx::Class create ErrorGenerator {
        :public method raise_unexpected_message_error {} {

        }

        :public method raise_unexpected_message_args_error {} {

        }

        :public method raise_similar_message_args_error {} {

        }

        :public method raise_expectation_error {} {

        }

        # TODO: Ordering?
        # :public method raise_out_of_order_error {} {
        # }

        :protected method __raise { message } {
            return -code error -level 2 -errorcode ::Spec::Mocks::ExpectationError $message
        }

        :protected method count_message { count } {
            :pretty_print $count
        }

        :protected method pretty_print { count } {
            return "$count time[expr { $count == 1 ? "" : "s" }]"
        }

        :protected method arg_list { args } {
            set result [list]
            foreach arg $args {
                if { [::nsf::is object $arg] && "description" in [$arg info lookup methods] } {
                    lappend result [$arg description]
                } else {
                    lappend result $arg
                }
            }
            join $result " "
        }

        :protected method format_args { args } {
            if { [llength $args] == 0 } {
                return "(no args)"
            } else {
                return "([:arg_list $args])"
            }
        }
    }
}