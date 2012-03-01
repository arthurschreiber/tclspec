nx::Class create ::Spec::Mocks::TclErrorGenerator {
    :property {options {}}

    :public method raise_expectation_error { method expected_received_count actual_received_count args } {
        set message "${method}[:format_args {*}${args}]"
        append message "\n    expected: [:count_message ${expected_received_count}]"
        append message "\n    received: [:count_message ${actual_received_count}]"

        :__raise $message
    }

    :public method raise_unexpected_message_error { method_name args } {
        set message "received unexpected message: $method_name with [:format_args {*}$args]"

        :__raise $message
    }

    :public method raise_unexpected_message_args_error { expectation args } {
        if { "expected_args" in [$expectation info vars] } {
            set expected_args [:format_args {*}[$expectation expected_args]]
        } else {
            set expected_args "(no args)"
        }
        set actual_args [:format_args {*}$args]

        set message "received [$expectation method_name] with unexpected arguments"
        append message "\n  expected: $expected_args"
        append message "\n       got: $actual_args"

        :__raise $message
    }

    :protected method __raise { message } {
        return -code error -errorcode ::Spec::Mocks::ExpectationError $message
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

nx::Class create ::Spec::Mocks::ProcDouble {
    :property proc_name:required

    :property {expectations {}}
    :property {stubs {}}

    :variable stashed false

    :public method add_expectation { error_generator {block {}} } {
        :configure_method

        if { [llength ${:stubs}] > 0 } {
            set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -method_block $block -return_block [[lindex ${:stubs} 0] return_block]]
        } else {
            set expectation [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -method_block $block]
        }

        set :expectations [concat [list $expectation] ${:expectations}]
        return $expectation
    }

    :public method add_negative_expectation { error_generator } {
        :configure_method

        set expectation [NegativeMessageExpectation new -error_generator $error_generator -method_name ${:proc_name}]
        set :expectations [concat [list $expectation] ${:expectations}]
        return $expectation
    }

    :public method add_stub { error_generator {implementation {}} } {
        :configure_method

        set stub [MessageExpectation new -error_generator $error_generator -method_name ${:proc_name} -return_block $implementation]
        set :stubs [concat [list $stub] ${:stubs}]
        return $stub
    }

    :public method remove_stub {} {
        set :stubs [list]
    }


    :public method find_matching_expectation { args } {
        foreach expectation ${:expectations} {
            if { [$expectation matches_args? {*}$args] } {
                if { ![$expectation called_max_times?] } {
                    return $expectation
                }
            }
        }

        foreach expectation ${:expectations} {
            if { [$expectation matches_args? {*}$args] } {
                return $expectation
            }
        }

        return false
    }

    :public method find_almost_matching_expectation { args } {
        foreach expectation ${:expectations} {
            if { ![$expectation matches_args? {*}$args] } {
                if { ![$expectation called_max_times?] } {
                    return $expectation
                }
            }
        }

        return false
    }

    :public method find_matching_method_stub { args } {
        foreach stub ${:stubs} {
            if { [$stub matches_args? {*}$args] } {
                return $stub
            }
        }

        return false
    }

    :public method configure_method { } {
        if { !${:stashed} } {
            :stash_original_method
            :define_proxy_method
        }
    }

    :public method stashed_proc_name {} {
        return "${:proc_name}_obfuscated_by_tclspec_"
    }

    :public method stash_original_method {} {
        set :stashed true

        if { [info procs ${:proc_name}] == ${:proc_name} } {
            rename ${:proc_name} [:stashed_proc_name]
        }
    }

    :public method define_proxy_method {} {
        proc ${:proc_name} { args } "
            \[::Spec::Mocks::TclDoubler new] message_received {${:proc_name}} {*}\$args
        "
    }

    :public method restore_original_method {} {
        if { ${:stashed} } {
            rename ${:proc_name} {}

            if { [info procs [:stashed_proc_name]] == [:stashed_proc_name] } {
                rename [:stashed_proc_name] ${:proc_name}
            }

            set :stashed false
        }
    }

    :public method verify {} {
        foreach expectation ${:expectations} {
            $expectation verify_messages_received
        }
    }

    :public method reset {} {
        :restore_original_method
    }
}

namespace eval ::Spec::ExampleProcs {
    # Replace a tcl command with a custom implementation.
    proc stub_call { args } {
        ::Spec::Mocks::TclDoubler stub_call {*}$args
    }

    # Replace a tcl command with a custom implementation and a
    # call expectation.
    proc mock_call { args } {
        ::Spec::Mocks::TclDoubler mock_call {*}$args
    }

    # Replace a tcl command with a negative call expectation.
    proc dont_call { args } {
        ::Spec::Mocks::TclDoubler dont_call {*}$args
    }
}

nx::Class create ::Spec::Mocks::TclDoubler {
    :property [list proc_doubles [dict create]]

    # Make this a singleton
    :public class method create {args} {
        if { ![info exists :instance] } {
            set :instance [next]
            [::Spec::Mocks space] add [:]
        }

        return ${:instance}
    }

    :public class method stub_call { proc_name -with -and_return {-any_number_of_times:switch false} } {
        set expectation [[:new] add_stub $proc_name]

        if { [info exists with] } {
            $expectation with $with
        }

        if { $any_number_of_times } {
            $expectation any_number_of_times
        }

        if { [info exists and_return] } {
            $expectation and_return $and_return
        }

        return $expectation
    }

    :public class method mock_call { proc_name -with -and_return {-any_number_of_times:switch false} } {
        set expectation [[:new] add_message_expectation $proc_name]

        if { [info exists with] } {
            $expectation with $with
        }

        if { $any_number_of_times } {
            $expectation any_number_of_times
        }

        if { [info exists and_return] } {
            $expectation and_return $and_return
        }

        return $expectation
    }

    :public class method dont_call { proc_name -with } {
        set expectation [[:new] add_negative_message_expectation $proc_name]

        if { [info exists with] } {
            $expectation with $with
        }

        return $expectation
    }

    :protected method init {} {
        set :error_generator [::Spec::Mocks::TclErrorGenerator new]
    }

    :public method message_received { proc_name args } {
        set expectation [:find_matching_expectation $proc_name {*}$args]
        set stub [:find_matching_method_stub $proc_name {*}$args]

        if { $stub != false && ($expectation == false || [$expectation called_max_times?]) } {
            if { $expectation != false && [$expectation actual_received_count_matters?] } {
                $expectation increase_actual_receive_count
            }

            $stub invoke {*}$args
        } elseif { $expectation != false } {
            $expectation invoke {*}$args
        } elseif { [set expectation [:find_almost_matching_expectation $proc_name {*}$args]] != false } {
            if { ![:has_negative_expectation? $proc_name] } {
                return -code error -errorcode ::Spec::Mocks::ExpectationError "Received unexpected call to $proc_name"
            }
        }
    }

    :public method has_negative_expectation? { proc_name } {
        foreach expectation [[:proc_double_for $proc_name] expectations] {
            if { [$expectation negative_expectation_for? $proc_name] } {
                return true
            }
        }

        return false
    }

    :public method find_matching_expectation { proc_name args } {
        [:proc_double_for $proc_name] find_matching_expectation {*}$args
    }

    :protected method find_almost_matching_expectation { proc_name args } {
        [:proc_double_for $proc_name] find_almost_matching_expectation {*}$args
    }

    :protected method find_matching_method_stub { proc_name args } {
        [:proc_double_for $proc_name] find_matching_method_stub {*}$args
    }

    :public method add_message_expectation { proc_name {block {}} } {
        [:proc_double_for $proc_name] add_expectation ${:error_generator} $block
    }

    :public method add_negative_message_expectation { proc_name } {
        [:proc_double_for $proc_name] add_negative_expectation ${:error_generator}
    }

    :public method add_stub { proc_name {implementation {}} } {
        [:proc_double_for $proc_name] add_stub ${:error_generator} $implementation
    }

    :public method remove_stub { proc_name } {
        [:proc_double_for $proc_name] remove_stub
    }

    :public method proc_double_for { proc_name } {
        if { ![dict exists ${:proc_doubles} $proc_name] } {
            set pd [ProcDouble new -proc_name $proc_name]
            dict set :proc_doubles $proc_name $pd
        }

        dict get ${:proc_doubles} $proc_name
    }

    :public method spec_verify {} {
        dict for {_ proc_double} ${:proc_doubles} {
            $proc_double verify
        }
    }

    :public method spec_reset {} {
        dict for {_ proc_double} ${:proc_doubles} {
            $proc_double reset
        }
    }
}