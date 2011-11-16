package provide try 1.0

namespace eval ::try {
    # These are not local, since this allows us to [uplevel] a [catch] rather than
    # [catch] the [uplevel]ing of something, resulting in a cleaner -errorinfo:
    variable em {}
    variable opts {}

    set ON_CODES { ok 0 error 1 return 2 break 3 continue 4 }

    proc throw {type message} {
        return -code error -errorcode $type -errorinfo $message -level 2 $message
    }

    # For future reference: rethrow can be implemented by adding a "-rethrow"
    # key to the return options dict
    # proc ::try::rethrow {{type {}} {message {}}} {
    #   return -code error -errorcode $type -rethrow 1 $message
    # }

    proc try {args} {
        variable ON_CODES

        # Check parameters
        set try_block [lindex $args 0]
        set handlers {}
        set finally {}
        set as_result {}
        set as_options {}
        set i 1

        # Optional "as {resultVarName ?optionsVarName?}"
        if { [lindex $args $i] eq "as" } {
            lassign [lindex $args $i+1] as_result as_options
            incr i 2
        }

        # Handlers & finally
        while { $i < [llength $args] } {
            switch -- [lindex $args $i] {
                "on" {
                    # on code variableList body
                    # translate code to integer
                    if { [scan [lindex $args $i+1] %d%c code dummy] != 1 } {
                        # not a number - try the magic keywords
                        if { [dict exists $ON_CODES [lindex $args $i+1]] } {
                            set code [dict get $ON_CODES [lindex $args $i+1]]
                        } else {
                            # otherwise its an error
                            break
                        }
                    }
                    # otherwise store the handler for later
                    lappend handlers "${code},*" [lindex $args $i+2] [lindex $args $i+3]
                    incr i 4
                }
                "trap" {
                    # trap pattern variableList body
                    # store the handler for later
                    lappend handlers "1,[lindex $args $i+1]" [lindex $args $i+2] [lindex $args $i+3]
                    incr i 4
                }
                "finally" {
                    # finally body (and no further handlers)
                    set finally [lindex $args $i+1]
                    incr i 2
                    break
                }
                default {
                    # unrecognised handler keyword
                    break
                }
            }
        }

        # If we broke out before the last arg (or need more args) then there is a
        # parameter problem
        # If the last handler body is a "-" then reject
        if { $i != [llength $args] || [lindex $handlers end] eq "-" } {
            error "wrong # args: should be \"try body ?as {resultVar ?optionsVar?}? ?on code body ...? ?trap pattern body ...? ?finally body?\""
        }

        # Execute the try_block, catching errors
        variable em
        variable opts
        set code [uplevel 1 [list ::catch $try_block \
            [namespace which -variable em] [namespace which -variable opts] ]]


        # Keep track of the original error message & options
        set _em $em
        set _opts $opts

        # Find and execute handler
        set errorcode {}
        if { [dict exists $_opts -errorcode] } {
            set errorcode [dict get $_opts -errorcode]
        }
        set exception "$code,$errorcode"

        set found false
        foreach {pattern variable_list body} $handlers {
            if { ! $found && ! [string match $pattern $exception] } continue
            set found true
            if { $body eq "-" } continue

            # Assign try body result to caller's variables
            if { [llength $variable_list] > 0 } {
                upvar [lindex $variable_list 0] _as_em
                set _as_em $em

                if { [llength $variable_list] > 1 } {
                    upvar [lindex $variable_list 1] _as_opt
                    set _as_opt $opts
                }
            }

            # Handler found - execute it
            set code [uplevel 1 [list ::catch $body \
                [namespace which -variable em] [namespace which -variable opts] ]]

            # Handler result replaces the original result (whether success or
            # failure); capture context of original exception for reference
            dict set opts -during $_opts
            set _em $em
            set _opts $opts

            # Handler has been executed - stop looking for more
            break
        }

        # No catch handler found -- error falls through to caller
        # OR catch handler executed -- result falls through to caller

        # If we have a finally block then execute it
        if { $finally ne {} } {
            set code [uplevel 1 [list ::catch $finally \
                [namespace which -variable em] [namespace which -variable opts] ]]

            # Finally result takes precedence except on success
            if { $code != 0 } {
                dict set opts -during $_opts
                set _em $em
                set _opts $opts
            }

            # Otherwise our result is not affected
        }

        # Propegate the error or the result of the executed catch body to the caller

        #FIXME -level 2 will hide the try...catch itself from errorInfo, but it
        #  breaks nested 'try { try ... catch } catch'
        dict incr _opts -level 1

        return -options $_opts $_em
    }

    namespace export try throw
}