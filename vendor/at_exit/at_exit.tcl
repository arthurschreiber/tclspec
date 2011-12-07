package provide at_exit 1.0

namespace eval ::at_exit {
    # List of handlers to be executed before the Tcl process exits.
    variable handlers {}

    # Register a handler (block of code or method name) to be executed before
    # the current Tcl process exits.
    #
    # See ::exit for more information.
    #
    # @param handler the handler to execute at exit.
    proc at_exit { handler } {
        lappend ::at_exit::handlers $handler
    }

    # Immediately terminate the process, without running any of the at_exit
    # handlers that have been installed. Returns returnCode to the system as
    # exit status.
    #
    # @param returnCode The code to return to the system as exit status.
    rename ::exit ::exit!

    # Terminate the process, after executing all registered at_exit handlers.
    #
    # Registered handlers are executed in the global scope, and handlers are
    # executed in reverse registration order, meaning that handlers that are
    # registered last will be executed first.
    #
    # Handlers can force an exist by calling either ::exit or ::exit!, which
    # both will cause an immediate process termination and no further execution
    # of any remaining at_exit handlers. The returned exit status to the system
    # will be the exit code that was passed to the last call to ::exit or
    # ::exit!.
    #
    # If an error occurs during the execution of an at_exit handler, the error
    # will be printed to stderr, and the execution of at_exit handlers will
    # continue. This will not affect the return code that was passed to the
    # initial call to ::exit.
    #
    # @param returnCode The code to return to the system as exit status.
    proc ::exit { {returnCode 0} } {
        rename ::exit ""
        proc ::exit { {returnCode 0} } {
            uplevel [list ::exit! $returnCode]
        }

        if { [info exists ::at_exit::handlers] } {
            # Run each of the at_exit handlers, but in reverse order.
            # This makes sure that exit handlers that were registered later
            # will have a higher priority.
            foreach handler [lreverse $::at_exit::handlers] {
                if { [catch [list uplevel #0 $handler]] } {
                    puts stderr $::errorInfo
                }
            }
        }

        # If none of the registered at_exit handlers has exited with a
        # different exit code, we can safely exit with the code that was originally
        # passed to the exit call
        exit $returnCode
    }

    namespace export at_exit
}