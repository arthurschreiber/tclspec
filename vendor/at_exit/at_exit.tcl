package provide at_exit 1.0

namespace eval ::at_exit {
    variable handlers {}

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
    #
    # @param handler the handler to execute at exit.
    proc at_exit { handler } {
        lappend ::at_exit::handlers $handler
    }

    rename ::exit ::exit!
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