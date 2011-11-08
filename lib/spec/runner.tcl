package require XOTcl
namespace import xotcl::*

# Register a handler (block of code or method name)
# to be executed before the current tcl process exits.
#
# Handlers are executed in the global scope, and handlers
# are executed in reverse registration order, meaning that
# handlers that were registered last will be executed first.
#
# A handler can force an exit by calling tcl's ::exit proc.
# No further at_exit handlers will then be executed.
#
# If an error occurs inside a handler, the error will be printed
# out to stderr, and the execution of at_exit handlers will continue.
#
# Errors inside an exit handler will not affect the return code with
# which ::exit was initially called. If an at_exit handler has to change
# the current script's exit code, the handler should execute ::exit
# with the desired code itself.
proc ::at_exit { at_exit_handler } {
    lappend ::at_exit_handlers $at_exit_handler
}

rename ::exit ::orig_exit
proc ::exit { {returnCode 0} } {
    # Restore the global exit proc, so that at_exit handlers
    # can exit with custom exit codes.
    rename ::exit ""
    rename ::orig_exit ::exit

    if { [info exists ::at_exit_handlers] } {
        # Run each of the at_exit handlers, but in reverse order.
        # This makes sure that exit handlers that were registered later
        # will have a higher priority.
        foreach at_exit_handler [lreverse $::at_exit_handlers] {
            if { [catch [list uplevel #0 $at_exit_handler]] } {
                puts stderr $::errorInfo
            }
        }
    }

    # If none of the registered at_exit handlers has exited with a
    # different exit code, we can safely exit with the code that was originally
    # passed to the exit call
    exit $returnCode
}

Class create Runner
Runner proc autorun {} {
    if { [my installed_at_exit?] } {
        return
    }

    my set installed_at_exit true
    at_exit { exit [Runner run] }
}

Runner proc run {} {
    set exit_code 0

    set reporter [Reporter new]

    $reporter report [$::world example_count] {
        foreach example_group [$::world set example_groups] {
            $example_group execute $reporter
        }
    }

    return $exit_code
}

Runner proc installed_at_exit? {} {
    expr { [my exists installed_at_exit] && [my set installed_at_exit] }
}
